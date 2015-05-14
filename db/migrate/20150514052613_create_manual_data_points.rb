class CreateManualDataPoints < ActiveRecord::Migration
  def change
    races = [
      {
        :title => "City Council District 4",
        :key   => "local.cc_district_4",
        :candidates => [
          "Carolyn Ramsay",
          "David Ryu"
        ]
      },
      {
        :title => "LAUSD School Board District 3",
        :key   => "local.lausd_district_3",
        :candidates => [
          "Tamar Galatzan",
          "Scott Mark Schmerelson"
        ]
      },
      {
        :title => "LAUSD School Board District 5",
        :key   => "local.lausd_district_5",
        :candidates => [
          "Bennett Kayser",
          "Ref Rodriguez"
        ]
      },
      {
        :title => "LAUSD School Board District 7",
        :key   => "local.lausd_district_7",
        :candidates => [
          "Lydia A. Gutiérrez",
          "Richard A. Vladovic"
        ]
      }
    ]

    group = "elections-may2015"

    DataPoint.create(
      :title        => "Percentage Reporting",
      :data_key     => "local:reporting",
      :data_value   => "0",
      :group_name   => group,
      :notes        => "no % symbol"
    )

    races.each do |race|

      race[:candidates].each do |candidate|
        candidate_key = race[:key] + ":" + candidate.parameterize.underscore

        DataPoint.create(
          :title        => candidate,
          :data_key     => candidate_key,
          :data_value   => "0",
          :group_name   => group,
          :notes        => "Percent Votes (no % symbol)"
        )
      end
    end
  end
end
