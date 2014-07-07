class ArticlePresenter < ApplicationPresenter
  presents :article

  def asset_display
    asset_display = article.original_object.asset_display
    if asset_display == :slideshow
      render 'shared/new/assets/slideshow', article: article
    elsif asset_display == :video
      render 'shared/new/assets/video', article: article
    elsif asset_display == :hidden || asset_display == :photo_deemphasized || article.original_object.assets.blank?
      render 'shared/new/assets/hidden', article: article
    else
      render 'shared/new/assets/photo', article: article
    end
  end

  def inline_asset
    if (article.original_object.asset_display == :photo_deemphasized) || (article.original_object.asset_display.blank? && !below_standard_ratio(width: article.asset.full.width, height: article.asset.full.height)) || (article.original_object.asset_display == :photo_emphasized && !below_standard_ratio(width: article.asset.full.width, height: article.asset.full.height))
      render 'shared/new/inline_asset', article: article
    end
  end
end
