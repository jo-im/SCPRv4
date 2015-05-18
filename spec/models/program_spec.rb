require 'spec_helper'

describe Program do
  describe '::all' do
    it "mixes all KPCC and External programs" do
      kpcc      = create :kpcc_program
      external  = create :external_program

      Program.all.should eq [kpcc, external]
    end
  end

  describe '::find_by_slug' do
    it "returns a KPCC program if it's available" do
      kpcc      = create :kpcc_program
      external  = create :external_program

      Program.find_by_slug(kpcc.slug).should eq kpcc
    end

    it "looks at ExternalProgram if no KPCC program is available" do
      external  = create :external_program

      Program.find_by_slug(external.slug).should eq external
    end
  end

  describe '::find_by_slug!' do
    it 'finds program by slug if available' do
      program = create :kpcc_program
      Program.find_by_slug!(program.slug).should eq program
    end

    it 'raise AR::RNF if slug is not found' do
      expect { Program.find_by_slug!("lolnope") }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '::where' do
    before do
      @kpcc_program       = create :kpcc_program, air_status: 'online'
      @external_program   = create :external_program, air_status: 'onair'
      @another_program    = create :kpcc_program, air_status: 'nope'
    end

    it 'passes in the conditions to each Program model' do
      Program.where(air_status: %w{online onair})
      .should eq [@kpcc_program, @external_program]
    end

    it 'returns all programs if conditions is an empty hash' do
      Program.where({}).sort_by(&:obj_key)
      .should eq [@kpcc_program, @external_program,@another_program].sort_by(&:obj_key)
    end

    it "returns all programs if conditions is nil" do
      Program.where(nil).sort_by(&:obj_key)
      .should eq [@kpcc_program, @external_program,@another_program].sort_by(&:obj_key)
    end
  end
end
