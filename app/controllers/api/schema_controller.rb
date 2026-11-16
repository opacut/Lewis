# app/controllers/api/schema_controller.rb
class Api::SchemaController < ApplicationController
  def book
    render json: {
      attributes: {
        "id"          => { type: "integer", readonly: true },
        "title"       => { type: "string" },
        "author"      => { type: "string" },
        "location"    => { type: "string" },
        "description" => { type: "string" },
        "image_url"   => { type: "string", readonly: true },
        "tags"        => { type: "array",  readonly: true },
        "tag_names"   => { type: "array" },
        "created_at"  => { type: "string", readonly: true },
        "updated_at"  => { type: "string", readonly: true }
      },
      endpoints: {
        "all"     => { method: "GET",    path: "/books.json" },
        "find"    => { method: "GET",    path: "/books/:id.json" },
        "create"  => { method: "POST",   path: "/books.json" },
        "update"  => { method: "PATCH",  path: "/books/:id.json" },
        "destroy" => { method: "DELETE", path: "/books/:id.json" }
      }
    }
  end

  def tag
    render json: {
      attributes: {
        "id"   => { type: "integer", readonly: true },
        "name" => { type: "string" }
      },
      endpoints: {
        "all"     => { method: "GET",    path: "/tags.json" },
        "find"    => { method: "GET",    path: "/tags/:id.json" },
        "destroy" => { method: "DELETE", path: "/tags/:id.json" }
      }
    }
  end
end