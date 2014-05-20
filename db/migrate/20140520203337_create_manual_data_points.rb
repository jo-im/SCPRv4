class CreateManualDataPoints < ActiveRecord::Migration
  def change
    races = [
      {
        :title => "LAUSD Member Of The Board Of Education, Board District 1",
        :key   => "lausd.d1",
        :candidates => [
          "Genethia Hudley-Hayes",
          "Rachel C. Johnson",
          "Genethia Hudley-Hayes",
          "Rachel C. Johnson",
          "Alex Johnson",
          "Omarosa O. Manigault",
          "Hattie B. Mcfrazier",
          "George McKenna",
          "Sherlett Hendy Newbill"
        ]
      },
      {
        :title => "Long Beach Mayor",
        :key   => "lb_mayor",
        :candidates => [
          "Damon Dunn",
          "Robert Garcia"
        ]
      },
      {
        :title => "LA County Sheriff",
        :key   => "lac_sheriff",
        :candidates => [
          "Patrick L. Gomez",
          "James Hellmold",
          "Jim McDonnell",
          "Bob Olmsted",
          "Todd S. Rogers",
          "Paul Tanaka",
          "Lou Vince"
        ]
      },
      {
        :title => "LA County Supervisor 3rd District",
        :key   => "lac_supervisor.d3",
        :candidates => [
          "Pamela Conley Ulich",
          "John Duran",
          "Doug Fay",
          "Yuval Daniel Kremer",
          "Sheila Kuehl",
          "Rudy Melendez",
          "Eric Preven",
          "Bobby Shriver"
        ]
      }
    ]

    group = "elections-june2014"

    races.each do |race|
      DataPoint.create(
        :title        => race[:title],
        :data_key     => race[:key] + ":reporting",
        :data_value   => "0",
        :group_name   => group,
        :notes        => "no % symbol"
      )

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
