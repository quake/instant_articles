require "instant_articles/version"
require 'nokogiri'
require 'cgi'

module InstantArticles
  class Content

    MEDIA_ELEMENTS = %w(img iframe blockquote)
    SOCIAL_SERVICES = %w(instagram facebook twitter vine youtube)
    BLOCKQUOTES = %w(instagram-media twitter-tweet)

    def initialize(content)
      @doc = Nokogiri::HTML.parse(content)
      clean_content
    end

    def content_html
      @doc.xpath('//body').inner_html
    end

    protected

    def clean_content
      clean_paragraphs
      replace_media
      clean_figures
      clean_headlines
      clean_images
    end

    def clean_paragraphs
      @doc.xpath('//p').each do |p|
        if p.inner_html == "\u00A0" then p.remove end

        last_node = p
        if p.text.to_s.strip.length == 0
          if p.inner_html == ''
            p.remove
            next
          end
          if p > 'script'
            # we have a script tag - move out of the p tag
            p.swap(p.inner_html)
            next
          end
        end

        if p.inner_html.include? '<figure'
          figures = p > 'figure'
          content_parts = p.inner_html.split(%r{<figure\b[^>]*>.*?</figure>})
          content_parts.each_with_index do |cp, index|
            if index == 0
              p.inner_html = cp
            else
              last_node = last_node.after("<p>#{cp}</p>")
            end
            unless figures[index].nil?
              last_node = last_node.after(figures[index].to_html)
            end
          end
        end
      end
    end

    def replace_media
      MEDIA_ELEMENTS.each do |tag|
        # surround iframes and images
        elements = @doc.xpath("//#{tag}")
        elements.each do |element|
          # BlockQuotes
          if element.matches? 'blockquote'
            cls_name = element.attribute("class").nil? ? "" : element.attribute("class").value.to_s

            next unless [cls_name].any? { |i| BLOCKQUOTES.include? i }


            unless element.attribute('style').nil?
              element['style'] = element.attribute('style').value.to_s.gsub(/margin:[^;]+/, 'margin: 0 auto')
            end

          end

          # If adform skip swap
          src = element["src"]
          unless src.nil?
            next if src.include? "adform"
          end

          # Set iframe src to always HTTPS
          # Todo: When separated from admin cms, activate this feature again.
          if element.matches? 'iframe'
            unless src.nil?
              if src[0..1] == "//"
                element['src'] = "https:#{src}"
              else
                # just replace http: right of
                element['src'] = element['src'].gsub('http://', 'https://')
              end
            end
          end

          if element.matches?('blockquote')
            fig = @doc.create_element('figure')
            fig['class'] = 'op-interactive'
            iframe = @doc.create_element('iframe')
            element.before(fig)

            if element.next_element && element.next_element.matches?('script')
              script = element.next_element
              iframe.add_child(element)
              iframe.add_child(script)
            else
              iframe.add_child(element)
            end

            fig.add_child(iframe)
            return          
          else
            next if element.parent.matches? 'figure'
            element.swap("<figure>#{element.to_html}</figure>")
          end
        end
      end

      figures = @doc.xpath("//figure")
      figures.each do |f|
        cls_name = f.attribute("class").nil? ? "" : f.attribute("class").value.to_s
        if cls_name.include? "op-social"
          cls_name.gsub!('op-social', 'op-interactive')
          f['class'] = cls_name
        end
        next if cls_name.include? "op-interactive"
        html = f.inner_html
        next unless html.include?('iframe') || html.include?('blockquote')
        if SOCIAL_SERVICES.any? { |service| html.include? service }
          f['class'] = cls_name.empty? ? "op-interactive" : "#{cls_name} op-interactive"
        elsif html.include? 'iframe'
          f['class'] = cls_name.empty? ? "op-interactive" : "#{cls_name} op-interactive"
        end
      end
    end


    def clean_figures
      figures = @doc.xpath('//figure/figure')
      figures.each do |f|
        f.parent.swap(f.to_html)
      end
    end

    def clean_headlines
      (3..6).to_a.each do |hl|
        headlines = @doc.xpath("//h#{hl}")
        headlines.each do |headline|
          headline.swap("<h2>#{headline.inner_html}</h2>")
        end
      end
    end

    def clean_images
      @doc.xpath('//img').each do |img|
        if img.attr('data-mode').nil?
          img['data-mode'] = 'aspect-fit'
        end
        img.delete('width')
        img.delete('height')
        img.delete('style')
      end
    end

  end
end
