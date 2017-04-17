class IndexPrograms < ActiveRecord::Migration
  def up
    [KpccProgram.all, ExternalProgram.all].each(&:index)
  end
  def down
    # ¯\_(ツ)_/¯
  end
end
