require 'spec_helper'

describe Concern::Associations::PolymorphicProgramAssociation do
  describe '#program' do
    it "tracks the association" do
      program = create :kpcc_program
      post = create :test_class_post

      post.program = program
      post.save!
      post.versions.last.description.should match /Program/
    end
  end


  describe '#program_obj_key=' do
    it 'sets the program based on the program_obj_key' do
      program   = create :kpcc_program
      post      = build :test_class_post

      post.program.should eq nil

      post.program_obj_key = program.obj_key
      post.program.should eq program
    end
  end

  describe '#program_obj_key' do
    it "is nil if there is no program" do
      post = build :test_class_post
      post.program_obj_key.should eq nil
    end
  end
end
