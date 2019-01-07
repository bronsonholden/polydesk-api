class FoldersController < ApplicationController
  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @folders = Folder.all

      render json: @folders
    end
  end

  # GET /:identifier/folders/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      render json: @folder
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @folder = Folder.new(folder_params)

      if @folder.save
        render json: @folder, status: :created, location: @folder
      else
        render json: @folder.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      if @folder.update(folder_params)
        render json: @folder
      else
        render json: @folder.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      @folder.destroy
    end
  end

  private
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def folder_params
      params.permit(:name)
    end
end
