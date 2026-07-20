module Woodenbits
  module Helpers
    def apt_repo_exists?(repo_name)
      clean_name = repo_name.to_s.sub(/\.(list|sources)$/, '')
      base_path = "/etc/apt/sources.list.d/#{clean_name}"
      ::File.exist?("#{base_path}.list") || ::File.exist?("#{base_path}.sources")
    end
  end
end

Chef::DSL::Recipe.include(Woodenbits::Helpers)
Chef::Resource.include(Woodenbits::Helpers)
