# frozen_string_literal: true


namespace :archives_online do
  desc 'Generate a sitemap from the EAD XML in the public directory'
  task generate_sitemap: :environment do

    ead_dir = Rails.root.join('public/ead')
    sitemap_out = Rails.root.join('public/sitemap.xml')

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') {

        Ead.all.each.each do |file|
          next unless file.filename.include?('xml')
          xml.url {
            ead_path = File.basename(file.filename, ".xml")
            xml.loc "https://archives.iu.edu/catalog/#{ead_path}"
            xml.lastmod file.last_indexed_at.to_time.strftime("%Y-%m-%dT%H:%M")
          }
        end
      }
    end

    File.write(sitemap_out, builder.to_xml)
  end
end
