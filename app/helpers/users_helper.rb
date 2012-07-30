module UsersHelper
  def role_selectors_for(form)
    form.select :roles, options_for_select(User.values_for_roles), {},
          {:multiple => true}
  end
end
