# -*- encoding : utf-8 -*-
require 'git_stats/hash_initializable'

module GitStats
  module GitData
    class Author
      include HashInitializable

      attr_reader :repo, :name, :email

      def commits
        @commits ||= repo.commits.select { |commit| commit.author == self }
      end

      def changed_lines
        insertions + deletions
      end

      def insertions
        num_stats.map(&:insertions).sum
      end

      def deletions
        num_stats.map(&:deletions).sum
      end

      def commits_sum_by_date
        sum = 0
        commits.map { |commit|
          sum += 1
          [commit.date, sum]
        }
      end

      def commits_sum_by_day
        commits.group_by{|c| Date.parse(c.date.to_s)}.map{|k, v| [k, v.count]}
      end

      [:insertions, :deletions, :changed_lines].each do |method|
        define_method "#{method}_by_date" do
          sum = 0
          commits.map { |commit|
            sum += commit.num_stat.send(method)
            [commit.date, sum]
          }
        end

        define_method "#{method}_by_day" do
          commits.group_by{|c| Date.parse(c.date.to_s)}.map do |k, v|
            [k, v.map{|commit| commit.num_stat.send(method) }.inject(0, :+)]
          end
        end
      end

      def short_stats
        commits.map(&:short_stat)
      end

      def num_stats
        commits.map(&:num_stat)
      end

      def activity
        @activity ||= Activity.new(commits)
      end

      def dirname
        @name.underscore.split.join '_'
      end

      def to_s
        "#{self.class} #@name <#@email>"
      end

      def ==(other)
        [self.repo, self.name, self.email] == [other.repo, other.name, other.email]
      end

    end
  end
end
