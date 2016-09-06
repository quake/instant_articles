require 'spec_helper'
require 'instant_articles'

describe InstantArticles do
  
  def cleaned_content(html)
    cleaned_value(InstantArticles::Content.new(html).content_html)
  end
  
  def cleaned_value(value)
    value.gsub(/\s+/,'')
  end


  it "moves embedded videos and iframes into a figure tag" do
    html1 = <<-HTML
        <p>Det här är 7-åriga Audrianna. Hon vill inte leka som de andra flickorna på hennes skola. I stället för att leka med dockor och klä sig i klänningar föredrar hon att bära jeans och ge sig ut på våghalsiga cykelturer. Det tyckte inte hennes skolkamrater om och Audrianna blev mobbad och hånad i skolan, enligt <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">ABC News</a>.<br>
<figure id="attachment_150551" style="width: 600px" class="wp-caption alignnone"><img src="http://s3.eu-central-1.amazonaws.com/cdn.newsner.com/attachments/images/000/247/769/newsner_default/flickan.jpg?1465318999" alt="Foto: Youtube." width="600" height="600" class="size-newsner-default wp-image-150551" sizes="(max-width: 600px) 100vw, 600px"><figcaption class="wp-caption-text">Foto: <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">Youtube</a>.</figcaption></figure></p>
    HTML
    expected1 = <<-HTML
        <p>Det här är 7-åriga Audrianna. Hon vill inte leka som de andra flickorna på hennes skola. I stället för att leka med dockor och klä sig i klänningar föredrar hon att bära jeans och ge sig ut på våghalsiga cykelturer. Det tyckte inte hennes skolkamrater om och Audrianna blev mobbad och hånad i skolan, enligt <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">ABC News</a>.<br>
</p><figure id="attachment_150551" style="width: 600px" class="wp-caption alignnone"><img src="http://s3.eu-central-1.amazonaws.com/cdn.newsner.com/attachments/images/000/247/769/newsner_default/flickan.jpg?1465318999" alt="Foto: Youtube." class="size-newsner-default wp-image-150551" sizes="(max-width: 600px) 100vw, 600px" data-mode="aspect-fit"><figcaption class="wp-caption-text">Foto: <a href="https://www.youtube.com/watch?v=Ux6-CGc5KbU&amp;feature=youtu.be" target="_blank">Youtube</a>.</figcaption></figure>
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
          <iframe><blockquote class="instagram-media">
          </blockquote></iframe>
        </figure>
    HTML

    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "centers instagram iframes" do
    html1 = <<-HTML
        <blockquote class="instagram-media" style="border: 0px; max-width: 658px; width: calc(100% - 2px);margin: 1px;border-radius: 4px; box-shadow: rgba(0, 0, 0, 0.498039) 0px 0px 1px 0px, rgba(0, 0, 0, 0.14902) 0px 1px 10px 0px; display: block; padding: 0px; background: rgb(255, 255, 255);"></blockquote>
    HTML
    expected1 = <<-HTML
        <figure class="op-interactive"><iframe><blockquote class="instagram-media" style="border: 0px; max-width: 658px; width: calc(100% - 2px);margin: 0 auto;border-radius: 4px; box-shadow: rgba(0, 0, 0, 0.498039) 0px 0px 1px 0px, rgba(0, 0, 0, 0.14902) 0px 1px 10px 0px; display: block; padding: 0px; background: rgb(255, 255, 255);"></blockquote></iframe></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "removes double figure tags" do
    html1 = <<-HTML
        <p><figure><figure><img src="example.jpg"></figure></figure></p>
    HTML
    expected1 = <<-HTML
        <figure><img src="example.jpg" data-mode="aspect-fit"></figure>
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

  it "surrounds instagram blockquoute with figure tag around the script tag also" do
    html1 = <<-HTML
      <blockquote class="instagram-media" style="background: #FFF; border: 0; border-radius: 3px; box-shadow: 0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 0 auto; max-width: 658px; padding: 0; width: calc(100% - 2px);" data-instgrm-captioned="" data-instgrm-version="7">
      <div style="padding: 8px;">
      <div style="background: #F8F8F8; line-height: 0; margin-top: 40px; padding: 50.0% 0; text-align: center; width: 100%;"> </div>
      <p style="margin: 8px 0 0 0; padding: 0 4px;"><a style="color: #000; font-family: Arial,sans-serif; font-size: 14px; font-style: normal; font-weight: normal; line-height: 17px; text-decoration: none; word-wrap: break-word;" href="https://www.instagram.com/p/BJbPk7xB5SD/" target="_blank">🐯. #cat #cats #catstagram #catsagram #instagood #kitten #kitty #kittens #pet #pets #animal #animals #petstagram #petsagram #photoftheday #catsofinstagram #ilovemycat #instagramcats #catoftheday #lovecats #furry #lovekittens #adorable #catlover #instacat #MyGreatCat #excellent_cats #bengal #bengalcat #cat_features</a></p>
      <p style="color: #c9c8cd; font-family: Arial,sans-serif; font-size: 14px; line-height: 17px; margin-bottom: 0; margin-top: 8px; overflow: hidden; padding: 8px 0 7px; text-align: center; text-overflow: ellipsis; white-space: nowrap;">Ett foto publicerat av Thor The Bengal (@bengalthor) <time style="font-family: Arial,sans-serif; font-size: 14px; line-height: 17px;" datetime="2016-08-22T21:14:24+00:00">Aug 22, 2016 kl. 2:14 PDT</time></p>
      </div>
      </blockquote>
      <script src="//platform.instagram.com/en_US/embeds.js"></script>
    HTML

    expected1 = <<-HTML
      <figure class="op-interactive"><iframe>
      <blockquote class="instagram-media" style="background: #FFF; border: 0; border-radius: 3px; box-shadow: 0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 0 auto; max-width: 658px; padding: 0; width: calc(100% - 2px);" data-instgrm-captioned="" data-instgrm-version="7">
      <div style="padding: 8px;">
      <div style="background: #F8F8F8; line-height: 0; margin-top: 40px; padding: 50.0% 0; text-align: center; width: 100%;"> </div>
      <p style="margin: 8px 0 0 0; padding: 0 4px;"><a style="color: #000; font-family: Arial,sans-serif; font-size: 14px; font-style: normal; font-weight: normal; line-height: 17px; text-decoration: none; word-wrap: break-word;" href="https://www.instagram.com/p/BJbPk7xB5SD/" target="_blank">🐯. #cat #cats #catstagram #catsagram #instagood #kitten #kitty #kittens #pet #pets #animal #animals #petstagram #petsagram #photoftheday #catsofinstagram #ilovemycat #instagramcats #catoftheday #lovecats #furry #lovekittens #adorable #catlover #instacat #MyGreatCat #excellent_cats #bengal #bengalcat #cat_features</a></p>
      <p style="color: #c9c8cd; font-family: Arial,sans-serif; font-size: 14px; line-height: 17px; margin-bottom: 0; margin-top: 8px; overflow: hidden; padding: 8px 0 7px; text-align: center; text-overflow: ellipsis; white-space: nowrap;">Ett foto publicerat av Thor The Bengal (@bengalthor) <time style="font-family: Arial,sans-serif; font-size: 14px; line-height: 17px;" datetime="2016-08-22T21:14:24+00:00">Aug 22, 2016 kl. 2:14 PDT</time></p>
      </div>
      </blockquote>
      <script src="//platform.instagram.com/en_US/embeds.js"></script>
      </iframe></figure>
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


  it 'replaces all headlines except h1 with h2' do
    html = <<-HTML
      <h4>test</h4><h3>test</h3>
    HTML
    expected = <<-HTML
      <h2>test</h2><h2>test</h2>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end

  it 'surrounds instagram embeds with iframe and figure' do
    html = <<-HTML
      <blockquote class="instagram-media"></blockquote>
    HTML
    expected = <<-HTML
      <figure class="op-interactive"><iframe><blockquote class="instagram-media"></blockquote></iframe></figure>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end

  it 'adds data-mode to images' do
    html = <<-HTML
      <img src="test.jpg">
    HTML
    expected = <<-HTML
      <figure><img src="test.jpg" data-mode="aspect-fit"></figure>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end

  it 'removes width and height attributes from images' do
    html = <<-HTML
      <img src="test.jpg" width="200" height="500">
    HTML
    expected = <<-HTML
      <figure><img src="test.jpg" data-mode="aspect-fit"></figure>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end

  it 'removes style attributes from images' do
    html = <<-HTML
      <img src="test.jpg" style="width:500px">
    HTML
    expected = <<-HTML
      <figure><img src="test.jpg" data-mode="aspect-fit"></figure>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end

  it 'should wrap if next item is script to a figure' do
    html = <<-HTML
    <figure class="op-interactive">
        <blockquote class="instagram-media" style="background: #FFF; border: 0; border-radius: 3px; box-shadow: 0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 0 auto; max-width: 658px; padding: 0; width: calc(100% - 2px);" data-instgrm-captioned="" data-instgrm-version="7">
            <div style="padding: 8px;">
                <div style="background: #F8F8F8; line-height: 0; margin-top: 40px; padding: 50% 0; text-align: center; width: 100%;"></div>
                <p style="margin: 8px 0 0 0; padding: 0 4px;"><a style="color: #000; font-family: Arial,sans-serif; font-size: 14px; font-style: normal; font-weight: normal; line-height: 17px; text-decoration: none; word-wrap: break-word;" href="https://www.instagram.com/p/xhyv3kg3c-/" target="_blank">#cat #cats #catstagram #catsagram #instagood #kitten #kitty #kittens #pet #pets #animal #animals #petstagram #petsagram #photoftheday #catsofinstagram #ilovemycat #instagramcats #nature #catoftheday #lovecats #furry #lovekittens #adorable #catlover #instacat #MyGreatCat #excellent_cats #bengal #bengalcat</a></p>
                <p style="color: #c9c8cd; font-family: Arial,sans-serif; font-size: 14px; line-height: 17px; margin-bottom: 0; margin-top: 8px; overflow: hidden; padding: 8px 0 7px; text-align: center; text-overflow: ellipsis; white-space: nowrap;">Ett foto publicerat av Thor The Bengal (@bengalthor) <time style="font-family: Arial,sans-serif; font-size: 14px; line-height: 17px;" datetime="2015-01-06T21:43:43+00:00">Jan 6, 2015 kl. 1:43 PST</time></p>
            </div>
        </blockquote>
    </figure>
    <script src="//platform.instagram.com/en_US/embeds.js"></script>
    HTML

    expected = <<-HTML
    <figure class="op-interactive">
      <iframe>
        <blockquote class="instagram-media" style="background: #FFF; border: 0; border-radius: 3px; box-shadow: 0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 0 auto; max-width: 658px; padding: 0; width: calc(100% - 2px);" data-instgrm-captioned="" data-instgrm-version="7">
          <div style="padding: 8px;">
              <div style="background: #F8F8F8; line-height: 0; margin-top: 40px; padding: 50% 0; text-align: center; width: 100%;"></div>
              <p style="margin: 8px 0 0 0; padding: 0 4px;"><a style="color: #000; font-family: Arial,sans-serif; font-size: 14px; font-style: normal; font-weight: normal; line-height: 17px; text-decoration: none; word-wrap: break-word;" href="https://www.instagram.com/p/xhyv3kg3c-/" target="_blank">#cat #cats #catstagram #catsagram #instagood #kitten #kitty #kittens #pet #pets #animal #animals #petstagram #petsagram #photoftheday #catsofinstagram #ilovemycat #instagramcats #nature #catoftheday #lovecats #furry #lovekittens #adorable #catlover #instacat #MyGreatCat #excellent_cats #bengal #bengalcat</a></p>
              <p style="color: #c9c8cd; font-family: Arial,sans-serif; font-size: 14px; line-height: 17px; margin-bottom: 0; margin-top: 8px; overflow: hidden; padding: 8px 0 7px; text-align: center; text-overflow: ellipsis; white-space: nowrap;">Ett foto publicerat av Thor The Bengal (@bengalthor) <time style="font-family: Arial,sans-serif; font-size: 14px; line-height: 17px;" datetime="2015-01-06T21:43:43+00:00">Jan 6, 2015 kl. 1:43 PST</time></p>
          </div>
        </blockquote>
        <script src="//platform.instagram.com/en_US/embeds.js"></script>        
      </iframe>  
    </figure>
    HTML
    expect(cleaned_content(html)).to eq(cleaned_value(expected))
  end
end
