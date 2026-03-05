require 'yaml'

class YamlTransformer
  def initialize(input_path)
    @data = YAML.load_file(input_path)
  end

  def transform

    hash = {}
    @data.each_key do |key|
      repo = @data.fetch(key, [])

      contact_tag = <<-CONTACT_TAG
<div class="al-repository-contact-phone">#{repo['phone']}</div>
<div class="al-repository-contact-info"><a href="mailto:#{repo['contact_info']}">#{repo['contact_info']}</a></div>
      CONTACT_TAG

      unless repo['repo_inst_url'].nil? || repo['repo_inst_url']&.empty?
        location_href = "<a href=\"#{repo['repo_inst_url']}\">#{repo['homepage_url_text'].nil? || repo['homepage_url_text']&.empty? ? "Visit " + repo['name'] : repo['homepage_url_text']}</a>"
      end
      location_tag = <<-LOCATION_TAG
<div class="al-repository-street-address-building">#{repo['building']}</div>
<div class="al-repository-street-address-address1">#{repo['address1']}</div>
<div class="al-repository-street-address-address2">#{repo['address2']}</div>
<div class="al-repository-street-address-city_state_zip_country">#{repo['city']}, #{repo['state']} #{repo['zip']}, #{repo['country']}</div>
#{location_href}
      LOCATION_TAG

      hash[key] = {
          'name' => repo['name'],
          'campus' => repo['campus'],
          'visit_note' => repo['visit_note'],
          'description' => repo['description'],
          'contact_html' => contact_tag,
          'location_html' => location_tag,
          'thumbnail_url' => repo['thumbnail_url']
      }
    end
    hash
  end
end

abort "Usage: ruby transform.rb input.yml output.yml" unless ARGV.size == 2
input_file, output_file = ARGV

transformer = YamlTransformer.new(input_file)
result = transformer.transform
File.write(output_file, YAML.dump(result))
