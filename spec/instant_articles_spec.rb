require 'spec_helper'
require 'instant_articles'

describe InstantArticles do
  
  def cleaned_content(html)
    cleaned_value(InstantArticles::Content.new(html).content_html)
  end
  
  def cleaned_value(value)
    value.gsub(/\s+/,'')
  end
  
  it "moves a figure right before the end of a paragraph out of the p tag" do
    html1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<figure><img src="example.com/img.jpg"></figure></p>
    HTML
    expected1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><figure><img src="example.com/img.jpg"></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "splits a paragraph with multiple figures into parts" do
    html1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. <figure><img src="example.com/img.jpg"></figure> Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<figure><img src="example.com/img.jpg"></figure></p>
    HTML
    expected1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p><figure><img src="example.com/img.jpg"></figure><p> Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><figure><img src="example.com/img.jpg"></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "moves embedded videos and iframes into a figure tag" do
    html1 = <<-HTML
        <p>Det här är 7-åriga Audrianna. Hon vill inte leka som de andra flickorna på hennes skola. I stället för att leka med dockor och klä sig i klänningar föredrar hon att bära jeans och ge sig ut på våghalsiga cykelturer. Det tyckte inte hennes skolkamrater om och Audrianna blev mobbad och hånad i skolan, enligt <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">ABC News</a>.<br>
<figure id="attachment_150551" style="width: 600px" class="wp-caption alignnone"><img src="http://s3.eu-central-1.amazonaws.com/cdn.newsner.com/attachments/images/000/247/769/newsner_default/flickan.jpg?1465318999" alt="Foto: Youtube." width="600" height="600" class="size-newsner-default wp-image-150551" sizes="(max-width: 600px) 100vw, 600px"><figcaption class="wp-caption-text">Foto: <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">Youtube</a>.</figcaption></figure></p>
    HTML
    expected1 = <<-HTML
        <p>Det här är 7-åriga Audrianna. Hon vill inte leka som de andra flickorna på hennes skola. I stället för att leka med dockor och klä sig i klänningar föredrar hon att bära jeans och ge sig ut på våghalsiga cykelturer. Det tyckte inte hennes skolkamrater om och Audrianna blev mobbad och hånad i skolan, enligt <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">ABC News</a>.<br>
</p><figure id="attachment_150551" style="width: 600px" class="wp-caption alignnone"><img src="http://s3.eu-central-1.amazonaws.com/cdn.newsner.com/attachments/images/000/247/769/newsner_default/flickan.jpg?1465318999" alt="Foto: Youtube." width="600" height="600" class="size-newsner-default wp-image-150551" sizes="(max-width: 600px) 100vw, 600px"><figcaption class="wp-caption-text">Foto: <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">Youtube</a>.</figcaption></figure>
    HTML

    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "removes p tags around script tags" do
    html1 = <<-HTML
        <p></p>
        <p>
        <script src="//platform.twitter.com/widgets.js"></script>
        </p>
    HTML
    expected1 = <<-HTML
        <script src="//platform.twitter.com/widgets.js"></script>
    HTML

    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "surrounds also iframes with a figure tag" do
    html1 = <<-HTML
        <p><iframe src="http://example.com" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></p>
    HTML

    expected1 = <<-HTML
        <figure class="op-interactive"><iframe src="https://example.com" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "does not wrap already wrapped elements" do
    html1 = <<-HTML
        <p><figure><iframe src="http://example.com" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></figure></p>
    HTML

    expected1 = <<-HTML
        <figure class="op-interactive"><iframe src="https://example.com" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "adds op-interactive class to social embeds" do
    html1 = <<-HTML
        <p><figure><iframe src="https://www.youtube.com/embed/3RwRUfx0g3Y" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></figure></p>
    HTML

    expected1 = <<-HTML
        <figure class="op-interactive"><iframe src="https://www.youtube.com/embed/3RwRUfx0g3Y" width="560" height="315" frameborder="0" allowfullscreen=""></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "replaces Instagram Blockquotes" do
    html1 = <<-HTML
        <blockquote class="instagram-media">
        </blockquote>
    HTML
    expected1 = <<-HTML
        <figure class="op-interactive">
          <blockquote class="instagram-media">
          </blockquote>
        </figure>
    HTML

    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "centers instagram iframes" do
    html1 = <<-HTML
        <blockquote class="instagram-media" style="border: 0px; max-width: 658px; width: calc(100% - 2px);margin: 1px;border-radius: 4px; box-shadow: rgba(0, 0, 0, 0.498039) 0px 0px 1px 0px, rgba(0, 0, 0, 0.14902) 0px 1px 10px 0px; display: block; padding: 0px; background: rgb(255, 255, 255);"></blockquote>
    HTML
    expected1 = <<-HTML
        <figure class="op-interactive"><blockquote class="instagram-media" style="border: 0px; max-width: 658px; width: calc(100% - 2px);margin: 0 auto;border-radius: 4px; box-shadow: rgba(0, 0, 0, 0.498039) 0px 0px 1px 0px, rgba(0, 0, 0, 0.14902) 0px 1px 10px 0px; display: block; padding: 0px; background: rgb(255, 255, 255);"></blockquote></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "removes double figure tags" do
    html1 = <<-HTML
        <p><figure><figure><img src="example.jpg"></figure></figure></p>
    HTML
    expected1 = <<-HTML
        <figure><img src="example.jpg"></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "adds op-interactive to already existing figure tags if they contain a social media iframe" do
    html1 = <<-HTML
        <figure><iframe src="https://www.youtube.com/whatever"></iframe></figure>
    HTML
    expected1 = <<-HTML
        <figure class="op-interactive"><iframe src="https://www.youtube.com/whatever"></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "adds op-interactive class to all other iframes" do
    html1 = <<-HTML
        <figure><iframe src="http://www.littlethings.com/video-embed.php?vid=WWul3O6q&amp;dfpid=19478"></iframe></figure>
    HTML
    expected1 = <<-HTML
        <figure class="op-interactive"><iframe src="https://www.littlethings.com/video-embed.php?vid=WWul3O6q&amp;dfpid=19478"></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "does not add a figure to any other blockquotes except instagram" do
    html1 = <<-HTML
        <blockquote></blockquote>
    HTML
    expected1 = <<-HTML
        <blockquote></blockquote>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "replaces op-social by op-interactive" do
    html1 = <<-HTML
      <figure class="op-social"><iframe src="http://www.littlethings.com/video-embed.php?vid=WWul3O6q&amp;dfpid=19478"></iframe></figure>
    HTML
    expected1 = <<-HTML
      <figure class="op-interactive"><iframe src="https://www.littlethings.com/video-embed.php?vid=WWul3O6q&amp;dfpid=19478"></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "surrounds tweets blockquoute with figure tag around the script tag also" do
    html1 = <<-HTML
      <blockquote class="twitter-tweet" data-lang="sv">
      <p dir="ltr" lang="en">Before they knew it, he dragged her across their yard.. <a href="https://t.co/sQwcDTk9fi">https://t.co/sQwcDTk9fi</a></p>
      HeroViral (@HeroViral) <a href="https://twitter.com/HeroViral/status/754754594765496320">17 juli 2016</a></blockquote>
      <script src="//platform.twitter.com/widgets.js"></script>
    HTML

    expected1 = <<-HTML
      <figure class="op-interactive"><iframe><blockquote class="twitter-tweet" data-lang="sv">
      <p dir="ltr" lang="en">Before they knew it, he dragged her across their yard.. <a href="https://t.co/sQwcDTk9fi">https://t.co/sQwcDTk9fi</a></p>
      HeroViral (@HeroViral) <a href="https://twitter.com/HeroViral/status/754754594765496320">17 juli 2016</a></blockquote><script src="//platform.twitter.com/widgets.js"></script></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end


  it "surrounds tweets blockquoute with figure tag around without script tag" do
    html1 = <<-HTML
      <blockquote class="twitter-tweet" data-lang="sv">
      <p dir="ltr" lang="en">Before they knew it, he dragged her across their yard.. <a href="https://t.co/sQwcDTk9fi">https://t.co/sQwcDTk9fi</a></p>
      HeroViral (@HeroViral) <a href="https://twitter.com/HeroViral/status/754754594765496320">17 juli 2016</a></blockquote>
    HTML

    expected1 = <<-HTML
      <figure class="op-interactive"><iframe><blockquote class="twitter-tweet" data-lang="sv">
      <p dir="ltr" lang="en">Before they knew it, he dragged her across their yard.. <a href="https://t.co/sQwcDTk9fi">https://t.co/sQwcDTk9fi</a></p>
      HeroViral (@HeroViral) <a href="https://twitter.com/HeroViral/status/754754594765496320">17 juli 2016</a></blockquote></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "replaces src with https:// when //..." do
    html1 = <<-HTML
      <iframe class="giphy-embed" src="//giphy.com/embed/34nMZ08nkNNmg" width="480" height="270" frameborder="0" allowfullscreen=""></iframe>
    HTML

    expected1 = <<-HTML
      <figure class="op-interactive"><iframe class="giphy-embed" src="https://giphy.com/embed/34nMZ08nkNNmg" width="480" height="270" frameborder="0" allowfullscreen=""></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "replaces src with https:// when http://..." do
    html1 = <<-HTML
      <iframe class="giphy-embed" src="http://giphy.com/embed/34nMZ08nkNNmg" width="480" height="270" frameborder="0" allowfullscreen=""></iframe>
    HTML

    expected1 = <<-HTML
      <figure class="op-interactive"><iframe class="giphy-embed" src="https://giphy.com/embed/34nMZ08nkNNmg" width="480" height="270" frameborder="0" allowfullscreen=""></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "should remove empty tags" do
    html1 = <<-HTML
      <p></p>
    HTML

    expected1 = <<-HTML
      
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end  

  it "should remove p tags with &nbsp;" do
    html1 = <<-HTML
      <p>&nbsp;</p>
    HTML

    expected1 = <<-HTML
    
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end  

end
