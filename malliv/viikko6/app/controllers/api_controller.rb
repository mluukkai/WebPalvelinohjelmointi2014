class ApiController < ApplicationController
  def search
    my_hash = BeermappingApi.raw(params[:city])
    render xml: my_hash.to_xml(:root => 'bmp_locations')
  end
end