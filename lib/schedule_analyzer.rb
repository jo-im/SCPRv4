class ScheduleAnalyzer < Array
  def problems
    _overlaps = overlaps
    _gaps     = gaps
    Hashie::Mash.new({overlaps: _overlaps, gaps: _gaps, any?: (_overlaps.any? || _gaps.any?)})
  end
  def overlaps
    select_groups do |a, b|
      a.recurring? && larger_or_starts_before?(a,b) && overlapping?(a,b) 
    end
  end
  def gaps
    select_pairs(flatten_schedule) do |a, b|
      ends_before?(a,b)
    end
    .map do |group|
      group.map do |occurrence|
        find {|o| o.id == occurrence.id}
      end
    end
  end
  private
  def flatten_schedule
    merged = []
    each do |occurrence|
      if merged.empty?
        merged << duplicate_occurrence(occurrence)
      else
        lower = merged.last
        if overlaps_ends_at?(occurrence, lower)
          lower.ends_at = occurrence.ends_at
          lower.id      = occurrence.id
        else
          merged << duplicate_occurrence(occurrence)
        end
      end
    end
    merged
  end
  def duplicate_occurrence occurrence
    attributes = occurrence.attributes
    cloned_occurrence = occurrence.dup
    cloned_occurrence.assign_attributes(attributes) # because Rails wrote dup to nullify some fields like ids
    cloned_occurrence
  end
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
end