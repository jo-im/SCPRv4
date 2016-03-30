require 'securerandom'
class Schedulizer < Array
  class << self
    def compare a, b
    # this is really only here to make it easier for testing
      a.map{|ary| ary.map{|o| o.to_h} }.to_s == b.map{|ary| ary.map{|o| o.to_h} }.to_s
    end
  end
  def initialize schedule_occurrences=[]
    super schedule_occurrences.map(&:to_schedulizer_occurrence)
    sort! # just in case
  end
  def problems
    _overlaps = find_overlaps
    _gaps     = find_gaps
    Hashie::Mash.new({overlaps: _overlaps, gaps: _gaps, any?: (_overlaps.any? || _gaps.any?)})
  end
  def sort!
    sort_by!(&:starts_at)
  end
  def discard!
    reject!(&:discard?)
  end
  def find_gaps
    reify.gaps
  end
  def find_overlaps
    duplicate.overlaps
  end
  def push object
    # don't allow object that can't be coerced into an occurrence
    super object.to_schedulizer_occurrence
  end
  def << object
    push object
  end
  def gaps
    select_pairs do |a, b|
      ends_before?(a,b)
    end
  end
  def overlaps
    select_groups do |a, b|
      unless a.precedence > b.precedence
        larger_or_starts_before?(a,b) && overlapping?(a,b)
      end
    end
  end
  private
  def select_pairs occurrences=self, &block
    output = []
    occurrences.each_cons(2) do |pair|
      next if pair.length < 2
      a, b = pair
      output << pair if yield a, b
    end
    output
  end
  def select_groups occurrences=self, &block
    output = []
    occurrences.each do |a|
      bin    = [a]
      each do |b|
        next if a == b
        bin << b if yield a, b
      end
      output << bin unless bin.one?
    end
    output    
  end
  def duplicate
    self.class.new to_a.map(&:dup)
  end
  def reify
    # makes the schedule "realistic", so that all occurrences are
    # contiguous and there are no logical overlaps
    merged = self.class.new # create a new Schedulizer instance
    each do |occurrence|
      occurrence = occurrence.dup
      if merged.empty?
        merged << occurrence
      else
        previous = merged.last
        mesh previous, occurrence
        merged << occurrence
      end
    end
    merged.discard! # clear out any discarded occurences
    merged
  end
  def overlapping? a, b
    between?(a,b) || overlaps_starts_at?(a,b) || overlaps_ends_at?(a,b) || completely_engulfing?(a,b)
  end
  def between? a, b # is a between b?
    (a.starts_at.to_i > b.starts_at.to_i) && (a.ends_at.to_i < b.ends_at.to_i)
  end
  def overlaps_starts_at? a, b
    (a.starts_at.to_i < b.starts_at.to_i) && (a.ends_at.to_i > b.starts_at.to_i)
  end
  def overlaps_ends_at? a, b
    (a.starts_at.to_i < b.ends_at.to_i) && (a.ends_at.to_i > b.ends_at.to_i)
  end
  def overlaps_edge? a, b
    overlaps_starts_at?(a, b) || overlaps_ends_at?(a, b)
  end
  def completely_engulfing? a, b
    (a.starts_at.to_i < b.starts_at.to_i) && (a.ends_at.to_i > b.ends_at.to_i)
  end
  def larger_or_starts_before? a, b
    a_size = (a.ends_at.to_i - a.starts_at.to_i)
    b_size = (b.ends_at.to_i - b.starts_at.to_i)
    (a_size > b_size) || (a_size == b_size && a.starts_at.to_i < b.starts_at.to_i)
  end
  def ends_before? a, b
    (a.ends_at.to_i < b.starts_at.to_i) && (a.ends_at.to_i != b.starts_at.to_i)
  end
  def larger_than? a, b
    a_size = a.ends_at - a.starts_at
    b_size = a.ends_at - b.starts_at
    a_size > b_size
  end
  def equivalent? a, b
    (a.starts_at == b.starts_at) && (a.ends_at == b.ends_at)
  end
  def mesh a, b
    # takes two occurrences and tries to "mesh" them together
    # so that there is no logical overlap
    a, b = [a, b].sort_by(&:starts_at) #just to guarantee the right result
    if equivalent?(a, b)
      mesh_equivalent(a, b)
    elsif completely_engulfing?(a, b)
      b.discard!
    elsif completely_engulfing?(b, a)
      a.discard!
    elsif overlaps_edge?(a, b)
      mesh_offset(a, b)
    end
  end
  def created_after? a, b
    if a.created_at && b.created_at
      a.created_at > b.created_at
    else
      false
    end
  end
  def created_before? a, b
    if a.created_at && b.created_at
      a.created_at < b.created_at
    else
      false
    end
  end
  def mesh_equivalent a, b
    unless discard_by_precedence(a, b)
      if created_after?(a, b)
        b.discard!
      else
        a.discard!
      end
    end
  end
  def mesh_offset a, b
    if a.precedence > b.precedence
      b.starts_at = a.ends_at
    elsif b.precedence > a.precedence
      a.ends_at = b.starts_at
    elsif !equivalent?(a, b)
      if a.starts_at < b.starts_at
        a.ends_at = b.starts_at
      elsif b.starts_at < a.starts_at
        b.ends_at = a.starts_at
      end
    end
  end
  def discard_by_precedence a, b
    if a.precedence > b.precedence
      b.discard!
    elsif b.precedence > a.precedence
      a.discard!
    else
      false
    end
  end
  public
  class Occurrence
    attr_accessor :guid, :starts_at, :ends_at, :metadata, :precedence, :discard, :created_at, :meshed
    alias_method :discard?, :discard
    alias_method :meshed?,  :meshed
    def initialize guid: SecureRandom.uuid, starts_at: nil, ends_at: nil, metadata: {}, precedence: 0, discard: false, created_at:nil, meshed: false
      # Assign arguments and their defaults to instance variables.  Neat, huh?
      method(__method__).parameters.each{|p| instance_variable_set("@#{p[1]}", binding.local_variable_get(p[1]))}
      self.metadata = Hashie::Mash.new(metadata)
    end
    def metadata= hash
      @metadata = Hashie::Mash.new(hash)
    end
    def to_schedulizer_occurrence
      self
    end
    def discard!
      @discard = true
    end
    def to_h
      {guid: guid, starts_at: starts_at, ends_at: ends_at}
    end
    [:starts_at, :ends_at].each do |n|
      define_method "display_#{n}" do
        Time.at(send(n)).try(:strftime, "%I:%M%P %-m/%-d")
      end
    end
  end
end