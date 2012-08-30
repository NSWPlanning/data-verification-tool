module DVT
  module PlanLabelInstanceMethods
    def dp?
      return false if dp_plan_number.nil?
      dp_plan_number.start_with?('DP')
    end

    def sp?
      return false if dp_plan_number.nil?
      dp_plan_number.start_with?('SP')
    end
  end
end
