require 'spec_helper'

describe Api::Public::V3::ScheduleOccurrencesController do
  request_params = {
    :format => :json
  }

  render_views

  describe 'GET /index' do
    it "returns this week's schedule by default" do
      occurrence1 = create :schedule_occurrence, starts_at: Time.zone.now
      occurrence2 = create :schedule_occurrence, starts_at: Time.zone.now.end_of_week

      get :index, request_params
      assigns(:schedule_occurrences).should eq [occurrence1, occurrence2]
    end

    it "uses the given start_time" do
      occurrence1 = create :schedule_occurrence, starts_at: Time.zone.now
      occurrence2 = create :schedule_occurrence, starts_at: Time.zone.now + 3.hours

      get :index, { start_time: (Time.zone.now + 1.hour).to_i }.merge(request_params)
      assigns(:schedule_occurrences).should eq [occurrence2]
    end

    it "uses the given length" do
      occurrence1 = create :schedule_occurrence, starts_at: Time.zone.now
      occurrence2 = create :schedule_occurrence, starts_at: Time.zone.now + 3.hours

      get :index, { start_time: (Time.zone.now - 1.hour).to_i, length: 2.hours }.merge(request_params)
      assigns(:schedule_occurrences).should eq [occurrence1]
    end

    it "returns error if start_time past a month from now" do
      get :index, { start_time: (Time.zone.now + 1.month + 1.day).to_i }.merge(request_params)
      response.body.should match /error/
    end

    context "pledge_status parameter is present" do 
      it "indicates if there is a pledge drive" do
        get :index, request_params.merge({pledge_status: true})
        pledge_drive_status = JSON.parse(response.body)["pledge_drive"]
        expect((pledge_drive_status == true || pledge_drive_status == false)).to eq true
      end
    end
    context "pledge_status parameter is not present" do
      it "does not include pledge status" do
        get :index, request_params
        pledge_drive_status = JSON.parse(response.body)["pledge_drive"]
        expect(pledge_drive_status).to eq nil
      end
    end

  end

  describe 'GET /show' do
    it "returns the schedule occurrence on at the requested time" do
      program = create :kpcc_program
      occurrence1 = create :schedule_occurrence, starts_at: 10.minutes.ago, program: program

      get :show, { at: Time.zone.now.to_i }.merge(request_params)
      assigns(:schedule_occurrence).should eq occurrence1
    end

    it 'is an empty object if nothing is on' do
      get :show, request_params
      JSON.parse(response.body)["schedule_occurrence"].should eq Hash.new
    end

    it "returns error if time past a month from now" do
      get :show, { time: (Time.zone.now + 1.month + 1.day).to_i }.merge(request_params)
      response.body.should match /error/
    end
  end
end
