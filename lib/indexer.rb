##
# Indexer
#
# Index sphinx on-the-fly using ThinkingSphinx.
# This is a light wrapper around Riddle::Controller
# Also includes hooks into Resque.
#
# Arguments: A list of model classes to index.
#
class Indexer
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_reader :indices, :models
  
  class << self
    #--------------------
    # Enqueue the Index task.
    def enqueue(*class_names)
      Resque.enqueue(Job::Index, class_names.map(&:to_s))
    end
  end

  #--------------

  def initialize(*models)
    @models     = models.reject { |m| m.blank? || !has_sphinx_indices?(m) }
    @controller = ThinkingSphinx::Configuration.instance.controller
    @indices    = @models.map { |m| sphinx_index_names(m) }.flatten
  end

  #--------------------
  # Index what needs to be indexed
  # If any models were passed in, only index those models.
  # If no classes passed in, run a full index.
  def index
    if @indices.empty?
      @controller.index
    else
      @controller.index @indices
    end
  end

  add_transaction_tracer :index, category: :task


  private

  def has_sphinx_indices?(model)
    !sphinx_indices(model).empty?
  end

  def sphinx_index_names(model)
    sphinx_indices(model).map(&:name)
  end

  def sphinx_indices(model)
    ThinkingSphinx::IndexSet.new([model], nil).to_a
  end
end
