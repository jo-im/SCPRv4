class Outpost::RecurringScheduleRulesController < Outpost::ResourceController
  outpost_controller
  skip_before_filter :require_login
  before_filter :clean_days, only: [:create, :update]

  define_list do |l|
    l.per_page = 200

    l.column :program, display: ->(r) { r.program.title }
    l.column :schedule, header: "Rule", display: ->(r) { r.schedule.to_s }
  end

  def preview
    @rule = Outpost.obj_by_key(params[:obj_key]) || RecurringScheduleRule.new
    with_rollback @rule do
      @rule.update(params[:recurring_schedule_rule])
      if @rule.unconditionally_valid?
        @problems = @rule.problems
        render "outpost/recurring_schedule_rules/preview",
          :locals => {
            :record   => @rule,
            :problems => @problems
          },
          :layout => "outpost/recurring_schedule_rules/preview"
      else
        render_preview_validation_errors(@rule)
      end
    end
  end

  private

  def clean_days
    params[:recurring_schedule_rule][:days] =
      params[:recurring_schedule_rule][:days].reject(&:blank?).map(&:to_i)
  end
end
