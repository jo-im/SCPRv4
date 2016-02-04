require "spec_helper"

describe Outpost::RecurringScheduleRulesController do
  render_views

  before :each do
    @admin_user = create :admin_user
    controller.stub(:current_user) { @admin_user }
  end

  describe 'day param' do
    it "removes blank items" do
      program = create :kpcc_program

      post :create, recurring_schedule_rule: {
        :interval           => 1,
        :days               => ["1", "2", "3","4", ""],
        :start_time         => "9:00",
        :end_time           => "11:00",
        :program_obj_key    => program.obj_key
      }

      controller.params[:recurring_schedule_rule][:days].should_not include ""
    end
  end

  describe 'preview' do
    it "shows schedule conflicts" do
      program1 = create :kpcc_program
      program2 = create :kpcc_program

      create :recurring_schedule_rule, {
        :interval           => 1,
        :days               => [1, 2, 3, 4],
        :start_time         => "9:00",
        :end_time           => "11:00",
        :program            => program1
      }

      put :preview, recurring_schedule_rule: {
        :interval           => 1,
        :days               => [1, 2, 3, 4],
        :start_time         => "8:00",
        :end_time           => "11:00",
        :program_obj_key    => program2.obj_key
      }

      response.should be_ok
      response.should render_template 'outpost/recurring_schedule_rules/preview'
      response.body.should =~ /issues/m
    end
  end
end
