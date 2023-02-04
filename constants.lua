local constants = {
    entity = {
        graphics = {},        
        input = {},
        output = {}
    },
    style = {}
}

constants.base_path = "__ImprovedCombinatorSE__"
constants.blank_image = constants.base_path.."/graphics/blank.png"
constants.gui_image = constants.base_path.."/graphics/gui.png"

constants.entity.name = "improved-combinator"
constants.entity.remnants = "improved-combinbator-remnants"
constants.entity.graphics.icon = constants.base_path.."/graphics/icons/improved-combinator.png"
constants.entity.graphics.technology_icon = constants.base_path.."/graphics/technology/improved-combinator.png"
constants.entity.graphics.image = constants.base_path.."/graphics/entity/improved-combinator.png"
constants.entity.graphics.hr_image = constants.base_path.."/graphics/entity/hr-improved-combinator.png"
constants.entity.graphics.image_shadow = constants.base_path.."/graphics/entity/improved-combinator-shadow.png"
constants.entity.graphics.hr_image_shadow = constants.base_path.."/graphics/entity/hr-improved-combinator-shadow.png"
constants.entity.graphics.remnants = constants.base_path.."/graphics/entity/remnants/improved-combinator-remnants.png"
constants.entity.graphics.hr_remnants = constants.base_path.."/graphics/entity/remnants/hr-improved-combinator-remnants.png"


constants.entity.input.name = "improved-combinator-input"
constants.entity.input.icon = constants.entity.graphics.icon
constants.entity.input.image = constants.base_path.."/graphics/blank.png"
constants.entity.input.circuit_wire_max_distance = 15

constants.entity.output.name = "improved-combinator-output"
constants.entity.output.icon = constants.entity.graphics.icon
constants.entity.output.image = constants.base_path.."/graphics/blank.png"
constants.entity.output.circuit_wire_max_distance = 15

-- Style Names --
constants.style.prefix_uuid = "ic_"
constants.style.dialogue_frame = constants.style.prefix_uuid.."dialogue_frame"
constants.style.main_frame = constants.style.prefix_uuid.."main_frame"
constants.style.main_tabbed_pane = constants.style.prefix_uuid.."main_tabbed_pane"
constants.style.signal_frame = constants.style.prefix_uuid.."signal_frame"
constants.style.signal_constants_frame = constants.style.prefix_uuid.."signal_constants_frame"
constants.style.signal_constants_inner_frame = constants.style.prefix_uuid.."signal_constants_inner_frame"
constants.style.signal_inner_frame = constants.style.prefix_uuid.."signal_inner_frame"
constants.style.signal_group_frame = constants.style.prefix_uuid.."signal_group_frame"
constants.style.signal_subgroup_frame = constants.style.prefix_uuid.."signal_subgroup_frame"
constants.style.signal_group_button_frame = constants.style.prefix_uuid.."signal_group_button_frame"
constants.style.signal_group_label = constants.style.prefix_uuid.."signal_group_label"
constants.style.signal_subgroup_scroll_frame = constants.style.prefix_uuid.."signal_subgroup_scroll_frame"
constants.style.signal_subgroup_button_frame = constants.style.prefix_uuid.."signal_subgroup_button_frame"
constants.style.signal_subgroup_selected_button_frame = constants.style.prefix_uuid.."signal_subgroup_selected_button_frame"
constants.style.tasks_frame = constants.style.prefix_uuid.."tasks_frame"
constants.style.conditional_frame = constants.style.prefix_uuid.."conditional_frame"
constants.style.sub_conditional_frame  = constants.style.prefix_uuid.."sub_conditional_frame"
constants.style.conditional_flow_frame = constants.style.prefix_uuid.."conditional_flow_frame"
constants.style.group_vertical_flow_frame = constants.style.prefix_uuid.."group_vertical_flow_frame"
constants.style.sub_group_vertical_flow_frame = constants.style.prefix_uuid.."sub_group_vertical_flow_frame"
constants.style.conditional_progress_frame = constants.style.prefix_uuid.."conditional_progress_frame" 
constants.style.scroll_pane_with_dark_background = constants.style.prefix_uuid.."scroll_pane_with_dark_background"
constants.style.scroll_pane = constants.style.prefix_uuid.."scroll_pane"
constants.style.callable_timer_label = constants.style.prefix_uuid.."callable_timer_label"
constants.style.callable_begining_label_frame = constants.style.prefix_uuid.."callable_begining_label_frame"
constants.style.repeatable_begining_label_frame = constants.style.prefix_uuid.."repeatable_begining_label_frame"
constants.style.play_button_frame = constants.style.prefix_uuid.."play_button_frame"
constants.style.time_selection_frame = constants.style.prefix_uuid.."time_selection_frame"
constants.style.close_button_frame = constants.style.prefix_uuid.."close_button_frame"
constants.style.repeatable_end_label_frame = constants.style.prefix_uuid.."repeatable_end_label_frame"
constants.style.task_dropdown_frame = constants.style.prefix_uuid.."task_dropdown_frame"
constants.style.subtask_dropdown_frame = constants.style.prefix_uuid.."subtask_dropdown_frame"
constants.style.condition_comparator_dropdown_frame = constants.style.prefix_uuid.."condition_comparator_dropdown_frame"
constants.style.callable_timer_dropdown_frame = constants.style.prefix_uuid.."callable_timer_dropdown_frame"
constants.style.dropdown_overlay_label_frame = constants.style.prefix_uuid.."dropdown_overlay_label_frame"
constants.style.dark_button_frame = constants.style.prefix_uuid.."dark_button_frame"
constants.style.dark_button_numbers_frame = constants.style.prefix_uuid.."dark_button_numbers_frame"
constants.style.dark_button_selected_frame = constants.style.prefix_uuid.."dark_button_selected_frame"
constants.style.dark_button_selected_numbers_frame = constants.style.prefix_uuid.."dark_button_selected_numbers_frame"
constants.style.invisible_frame = constants.style.prefix_uuid.."invisible_frame"
constants.style.radiobutton_frame = constants.style.prefix_uuid.."radiobutton_frame"
constants.style.radio_vertical_flow_frame = constants.style.prefix_uuid.."radio_vertical_flow_frame"
constants.style.combinator_horizontal_padding_frame = constants.style.prefix_uuid.."combinator_horizontal_padding_frame"
constants.style.screen_strech_frame = constants.style.prefix_uuid.."screen_strech_frame"
constants.style.signal_constants_value_frame = constants.style.prefix_uuid.."signal_constants_value_frame"
constants.style.constant_button_frame = constants.style.prefix_uuid.."constant_button_frame"

return constants