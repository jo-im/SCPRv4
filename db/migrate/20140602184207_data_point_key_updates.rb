class DataPointKeyUpdates < ActiveRecord::Migration
  def up
    DataPoint.all.each do |dp|
      dp.data_key.match(/\Aassembly\.(.+)/) do |m|
        dp.update_column(:data_key, "state.assembly-#{m[1]}")
      end

      dp.data_key.match(/\Asenate\.(.+)/) do |m|
        dp.update_column(:data_key, "state.senate-#{m[1]}")
      end

      dp.data_key.match(/\Aca\.(.+)/) do |m|
        dp.update_column(:data_key, "state.#{m[1]}")
      end

      dp.data_key.match(/\Asos:(.+)/) do |m|
        dp.update_column(:data_key, "state.sos:#{m[1]}")
      end

      dp.data_key.match(/\Aprop\.(.+)/) do |m|
        dp.update_column(:data_key, "state.prop-#{m[1]}")
      end

      dp.data_key.match(/\Alausd\.(.+)/) do |m|
        dp.update_column(:data_key, "local.lausd-#{m[1]}")
      end

      dp.data_key.match(/\Alb_mayor(.+)/) do |m|
        dp.update_column(:data_key, "local.lb_mayor#{m[1]}")
      end

      dp.data_key.match(/\Alac_sheriff(.+)/) do |m|
        dp.update_column(:data_key, "local.lac_sheriff#{m[1]}")
      end

      dp.data_key.match(/\Alac_supervisor\.(.+)/) do |m|
        dp.update_column(:data_key, "local.lac_supervisor-#{m[1]}")
      end

      if dp.data_key == "percent_reporting"
        dp.update_column(:data_key, "sos_feed:percent_reporting")
      end

      if dp.data_key == "show_results"
        dp.destroy
      end
    end
  end

  def down
    # no
  end
end
