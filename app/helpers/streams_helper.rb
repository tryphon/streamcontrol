module StreamsHelper

  def format_radio_button(form, format_presenter)
    data_attributes = {
      :"data-requires-bitrate" => format_presenter.requires_birate?, 
      :"data-requires-quality" => format_presenter.requires_quality?
    }
    form.radio_button :format, format_presenter.format, data_attributes
  end

  def format_radio_buttons(form)
    content_tag(:ul) do
      StreamFormatPresenter.all.collect do |format_presenter|
        content_tag(:li) do 
          [ format_radio_button(form, format_presenter),
            form.label("format_#{format_presenter.format}", format_presenter.name),
            link_to(image_tag('ui/help.png', :alt => '?'), format_presenter.wikipedia_url) ].join(" ")
        end
      end.join("\n")
    end
  end


end
