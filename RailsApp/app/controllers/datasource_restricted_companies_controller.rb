class DatasourceRestrictedCompaniesController < ApplicationController
  before_filter :user_with_privileges
  before_action :set_datasource_restricted_company, only: [:destroy]
  before_action :set_datasource,
                only: [:create, :destroy, :destroy_all_by_datasource]

  def create
    @allowed =
      DatasourceRestrictedCompany.new(datasource_restricted_companies_params)


    if @allowed.save
      render js :update_restricted_companies_form
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if @restricted.destroy
      render js :update_restricted_companies_form
    else
      head :unprocessable_entity
    end
  end

  def destroy_all_by_datasource
    if DatasourceRestrictedCompany.destroy_all(datasource_restricted_companies_params)
      render js :update_restricted_companies_form
    else
      head :unprocessable_entity
    end
  end

  private
    def set_datasource_restricted_company
      @restricted = DatasourceRestrictedCompany.find(params[:id])
    end

    def set_datasource
      condition = { id: datasource_restricted_companies_params[:datasource_id] }
      @datasource = Datasource.where(condition).first
    end

    def datasource_restricted_companies_params
      params.require(:datasource_restricted_company).permit(:datasource_id,
                                                            :company_id
                                                            )
    end
end
