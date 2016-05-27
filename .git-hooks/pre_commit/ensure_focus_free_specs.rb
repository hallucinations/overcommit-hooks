require 'rspec'

module Overcommit
  module Hook
    module PreCommit
      # NOTE: This makes use of many methods from RSpecs private API.
      class EnsureFocusFreeSpecs < Base
        def configure_rspec(applicable_files)
          RSpec.configure do |config|
            config.inclusion_filter = :focus
            config.files_or_directories_to_run = applicable_files
            config.inclusion_filter.rules
            config.requires = %w(spec_helper rails_helper)
            config.load_spec_files
          end
        end

        def run
          configure_rspec(applicable_files)
          return :pass if RSpec.world.example_count.zero?

          files = RSpec.world.filtered_examples.reject {|_k, v| v.empty?}.keys.map(&:file_path).uniq

          [:fail, "Trying to commit focused spec(s) in:\n\t#{files.join("\n\t")}"]
        end
      end
    end
  end
end
