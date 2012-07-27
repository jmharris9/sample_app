module ApplicationHelper


  # Returns the logo
  def logo
 	logo = image_tag("logo.png", alt: "Sample App", class: "round")
  end


  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Zoster"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end