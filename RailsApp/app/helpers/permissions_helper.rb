module PermissionsHelper

  %w[counts orders users user_files].each do |entity|
    klass = entity.classify.constantize

    define_method("visible_#{entity}") do
      if current_user.sysadmin?
        klass.all
      else
        klass.by_company(current_user.company_id)
      end      
    end
  end

end

