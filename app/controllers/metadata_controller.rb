class MetadataController < InheritedResources::Base
  defaults :singleton => true, :resource_class => Metadata, :instance_name => "metadata"

  actions :new, :create, :show
  respond_to :html, :xml, :json

  def show
    redirect_to new_metadata_path
  end

  def create
    create! do |success, failure|
      success.html { redirect_to new_metadata_path }
    end
  end

  private

  # :metadatas_url is used by InheritedResources #api_behavior
  # alias_method :metadatas_url, :new_metadata_url

end
