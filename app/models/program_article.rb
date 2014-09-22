class ProgramArticle < ActiveRecord::Base
  belongs_to :kpcc_program, :foreign_key => "program_id"

  belongs_to :article,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true

  def simple_json
    @simple_json ||= {
      "id"          => self.article.try(:obj_key),
      "position"    => self.position.to_i
    }
  end
end
