# -*- encoding : utf-8 -*-
module GitStats
  module GitData
    class NumStat
      attr_reader :commit, :files_changed, :insertions, :deletions, :short_insertions, :short_deletions

      def initialize(commit, ignore_files=[])
        @commit = commit
        @ignore_files = ignore_files
        calculate_stat
      end

      def changed_lines
        insertions + deletions
      end

      def to_s
        "#{self.class} #@commit"
      end

      private
      def calculate_stat
        lines = commit.repo.run("git show --numstat --no-merges --oneline --no-renames #{commit.sha} -- #{commit.repo.tree_path}").lines.to_a
        @files_changed = @insertions = @deletions = 0
        if lines.length > 1
          stat_lines = lines[1, lines.length].map{|line| line.split(' ')}.reject{|e| @ignore_files.include?(e[2])}
          if !stat_lines.blank?
            @files_changed = stat_lines.length
            @insertions = stat_lines.inject(0){|sum, e| sum + e[0].to_i}
            @deletions = stat_lines.inject(0){|sum, e| sum + e[1].to_i}
          end
        end
      end
    end
  end
end
