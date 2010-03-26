module StreamsHelper

  def format_radio_buttons(form)
    content_tag(:ul) do
      StreamFormatPresenter.all.collect do |format_presenter|
        content_tag(:li) do 
          [ form.radio_button(:format, format_presenter.format),
            form.label("format_#{format_presenter.format}", format_presenter.name),
            link_to(image_tag('ui/help.png', :alt => '?'), format_presenter.wikipedia_url) ].join(" ")
        end
      end.join("\n")
    end
  end

end
