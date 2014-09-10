class CreateProgramReporter < ActiveRecord::Migration
  def change
    create_table :program_reporters do |t|
      t.integer :bio_id
      t.integer :program_id
    end

    add_index :program_reporters, [:bio_id]
    add_index :program_reporters, [:program_id]
  end
end
