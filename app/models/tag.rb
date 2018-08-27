class Tag < Resource
  include ActiveModel::Model

  attr_accessor :repository, :name, :content_digest, :layers
  mattr_accessor :token

  def self.find(repository:, name:)
    response = client.get "/v2/#{repository.name}/manifests/#{name}" do |request|
      request.headers["Accept"] = "application/vnd.docker.distribution.manifest.v2+json"
      request.headers["Authorization"] = "Bearer #{token}"
    end

    layers = if response.headers["content-type"] =~ /v2/
      Array.wrap(response.body["layers"]).each_with_index.map do |layer, index|
        Layer.new(
          index:  index+1,
          digest: layer["digest"],
          size:   layer["size"]
        )
      end
    else
      Array.wrap(response.body["fsLayers"]).each_with_index.map do |layer, index|
        Layer.new(
          index:  index+1,
          digest: layer["blobSum"]
        )
      end
    end

    new(
      repository: repository,
      name: name,
      content_digest: response.headers["docker-content-digest"],
      layers: layers
    )
  end

  def delete
    client.delete "/v2/#{repository.name}/manifests/#{content_digest}"
    true
  end
end
