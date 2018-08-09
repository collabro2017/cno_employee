class CompaniesController < ApplicationController
  before_filter :user_with_privileges
  before_action :set_company, only: [:show, :edit, :update]

  def index
    @companies = Company.paginate(page: params[:page])
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      flash[:success] = "A new company has been created!"
      redirect_to companies_path
    else
      render 'new'
    end
  end

  def update
    if @company.update_attributes(company_params.symbolize_keys)
      flash[:success] = "A company has been updated!"
      redirect_to companies_path
    else
      render 'edit'
    end
  end

  def restricted_by_datasource
    @companies =  Company.restricted_by_datasource(
                    datasource_id: company_params[:datasource_id]
                  )
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :code, :datasource_id)      
    end
end

