class ParentsController < ApplicationController
   # GET /parents
   def index
    @client = Client.find(params[:client_id])
    @parents = @client.parents

    render json: @parents
  end

  # GET /parents/1
  def show
    @client = Client.find(params[:client_id])
    @parent = @client.parents.find_by(id: params[:id])
  
    if @parent.present?
      render json: @parent
    else
      render json: { error: 'Responsaveis não encontrado' }, status: :not_found
    end
  end

  # POST /parents
  def create
    @client = Client.find(params[:client_id])
    parents_params = params.require(:parents).map { |p| p.permit(:parent_name, :cpf, :degree_of_kinship, :email, :telephone) }
  
    created_parents = []
    failed_parents = []
  
    parents_params.each do |parent_params|
      parent = @client.parents.build(parent_params)
  
      if parent.save
        created_parents << parent
      else
        failed_parents << { parent: parent_params, errors: parent.errors.full_messages }
      end
    end
  
    if failed_parents.empty?
      render json: created_parents, status: :created
    else
      render json: { failed_parents: failed_parents }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /parents/1
  def update
    @client = Client.find(params[:client_id])
    @parent = @client.parents.find_by(id: params[:id])
  
    if @parent.present?
      if @parent.update(parent_params)
        render json: @parent
      else
        render json: @parent.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Responsável não encontrado ou não está associado ao cliente' }, status: :not_found
    end
  end

  # DELETE /parents/1
  def destroy
    @client = Client.find(params[:client_id])
    @parent = @client.parents.find_by(id: params[:id])
    
    if @parent.present?
      if @parent.destroy
        render json: { message: 'Responsável excluído com sucesso' }
      else
        render json: @parent.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Responsável não encontrado ou não está associado ao cliente' }, status: :not_found
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def parent_params
      params.require(:parent).permit(:parent_name, :cpf, :client_id, :degree_of_kinship, :email, :telephone)
    end
end
