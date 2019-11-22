# -*- encoding : utf-8 -*-
module GitStats
  module StatsView
    module Charts
      class AuthorsCharts
        AUTHORS_ON_CHART_LIMIT = 7

        def initialize(authors)
          @authors = authors
        end

        def commits_sum_by_author_by_date(authors = nil)
          Chart.new do |f|
            f.multi_date_chart(
                data: (authors || @authors.sort_by { |author| -author.commits.size }[0..AUTHORS_ON_CHART_LIMIT]).map { |author| {name: author.name, data: author.commits_sum_by_date} },
                title: :lines_by_date.t,
                y_text: :lines.t
            )
          end
        end

        def commits_sum_by_author_by_day(authors = nil)
          Chart.new do |f|
            f.multi_date_chart(
                data: (authors || @authors.sort_by { |author| -author.commits.size }[0..AUTHORS_ON_CHART_LIMIT]).map { |author| {name: author.name, data: author.commits_sum_by_day} },
                title: :lines_by_date.t,
                y_text: :lines.t
            )
          end
        end

        [:insertions, :deletions, :changed_lines].each do |method|
          define_method "#{method}_by_author_by_date" do |authors = nil|
            Chart.new do |f|
              f.multi_date_chart(
                  data: (authors || @authors.sort_by { |author| -author.send(method) }[0..AUTHORS_ON_CHART_LIMIT]).map { |author| {name: author.name, data: author.send("#{method}_by_date")} },
                  title: :lines_by_date.t,
                  y_text: :lines.t
              )
            end
          end

          define_method "#{method}_by_author_by_day" do |authors = nil|
            Chart.new do |f|
              f.multi_date_chart(
                  data: (authors || @authors.sort_by { |author| -author.send(method) }[0..AUTHORS_ON_CHART_LIMIT]).map { |author| {name: author.name, data: author.send("#{method}_by_day")} },
                  title: :lines_by_date.t,
                  y_text: :lines.t
              )
            end
          end

          def modified_by_author_by_day(author)
            data = []
            data << {name: "Insertion", data: author.send("insertions_by_day")}
            data << {name: "Deletion", data: author.send("deletions_by_day")}
            Chart.new do |f|
              f.multi_date_chart(
                  data: data,
                  title: :modified_by_day.t,
                  y_text: :lines.t
              )
            end
          end
        end

      end
    end
  end
end
