# frozen_string_literal: true


namespace :archives_online do
  desc 'Generate a sitemap from the EAD XML in the public directory'
  task generate_sitemap: :environment do

    ead_dir = Rails.root.join('public/ead')
    sitemap_out = Rails.root.join('public/sitemap.xml')

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') {

        Dir.new(ead_dir).each do |file|
          next unless file.include?('xml')
          xml.url {
            ead_path = File.basename(file, ".xml")
            xml.loc "https://archives.iu.edu/catalog/#{ead_path}"
            xml.lastmod Time.now.strftime("%Y-%m-%d")
          }
        end
      }
    end

    File.write(sitemap_out, builder.to_xml)
  end
end
