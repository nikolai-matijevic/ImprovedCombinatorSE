local constants = require("constants")

local function add_styles(styles)
    local default_styles = data.raw["gui-style"].default
    for name, style in pairs(styles) do
        default_styles[name] = style
    end
end

local default_dirt_color = {15, 7, 3, 100}

local default_shadow =
{
    position = {200, 128},
    corner_size = 8,
    tint = {0, 0, 0, 90},
    scale = 0.5,
    draw_type = "outer"
}   

local top_shadow =
{
    top = {position = {208, 128}, size = {1, 8}},
    center = {position = {208, 136}, size = {1, 1}},
    tint = default_shadow_color,
    scale = 0.5,
    draw_type = "outer"
}

local default_dirt =
{
    position = {200, 128},
    corner_size = 8,
    tint = default_dirt_color,
    scale = 0.5,
    draw_type = "outer"
}

local default_glow =
{
    position = {200, 128},
    corner_size = 8,
    tint = {225, 177, 106, 255},
    scale = 0.5,
    draw_type = "outer"
}

local default_inner_shadow =
{
    position = {183, 128},
    corner_size = 8,
    tint = {0, 0, 0, 255},
    scale = 0.5,
    draw_type = "inner"
}

function offset_by_2_rounded_corners_glow(tint_value)
    return
    {
        position = {240, 736},
        corner_size = 16,
        tint = tint_value,
        top_outer_border_shift = 4,
        bottom_outer_border_shift = -4,
        left_outer_border_shift = 4,
        right_outer_border_shift = -4,
        draw_type = "outer"
    }
end

add_styles({
    [constants.style.dialogue_frame] =
    {
        type = "frame_style",
        title_style =
        {
            type = "label_style",
            parent = "frame_title",
        },
        -- padding of the content area of the frame
        top_padding  = 4,
        right_padding = 8,
        bottom_padding = 4,
        left_padding = 8,
        graphical_set =
        {
            base = {position = {0, 0}, corner_size = 8},
            shadow = default_shadow
        },
        flow_style = { type = "flow_style" },
        horizontal_flow_style = { type = "horizontal_flow_style" },
        vertical_flow_style = { type = "vertical_flow_style" },
        header_flow_style =
        {
            type = "horizontal_flow_style",
            horizontally_stretchable = "on",
            bottom_padding = 4
        },
        header_filler_style =
        {
            type = "empty_widget_style",
            parent = "draggable_space_header",
            horizontally_stretchable = "on",
            vertically_stretchable = "on",
            height = 24
        },
        use_header_filler = true,
        drag_by_title = true,
        border = {}
    },
    [constants.style.main_frame] =
    {
        type = "frame_style",
        parent = constants.style.dialogue_frame,
        horizontally_stretchable = "on",
        vertically_stretchable = "on",

        top_padding  = 5,
        right_padding = 5,
        bottom_padding = 5,
        left_padding = 5,

        width = 406,
        height = 608,
    },
    [constants.style.main_tabbed_pane] =
    {
        type = "tabbed_pane_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        padding  = 12,
        width = 388,
        height = 0,
        tab_content_frame =
        {
            type = "frame_style",
            top_padding = 0,
            right_padding = 0,
            left_padding = 0,
            bottom_padding = 0,
            graphical_set =
            {
                base =
                {
                    top =
                    {
                        filename = constants.gui_image,
                        position = {12, 0}, size = {1, 24}
                    },
                    bottom =
                    {
                        filename = constants.gui_image,
                        position = {12, 0}, size = {1, 24}
                    },
                    left =
                    {
                        filename = constants.gui_image,
                        position = {0, 12}, size = {24, 1}
                    },
                    left_top =
                    {
                        filename = constants.gui_image,
                        position = {0, 24}, size = 24
                    },
                    left_bottom =
                    {
                        filename = constants.gui_image,
                        position = {0, 48}, size = 24
                    },
                    right =
                    {
                        filename = constants.gui_image,
                        position = {0, 12}, size = {24, 1}
                    },
                    right_top =
                    {
                        filename = constants.gui_image,
                        position = {24, 24}, size = 24
                    },
                    right_bottom =
                    {
                        filename = constants.gui_image,
                        position = {24, 48}, size = 24
                    },
                    draw_type = "outer"
                },
                shadow = default_inner_shadow
            },
        },
        tab_container =
        {
            type = "horizontal_flow_style",
            bottom_padding = 12,
            --left_padding = 12,
            --right_padding = 12,
            horizontal_spacing = 0
        }
    },
    [constants.style.signal_frame] =
    {
        type = "frame_style",
        parent = constants.style.main_frame,
        padding  = 8,
        width = 450,
        height = 0,
        horizontally_stretchable = "on"
    },
    [constants.style.signal_constants_frame] =
    {
        type = "frame_style",
        parent = constants.style.signal_frame,
        horizontally_stretchable = "off",
        vertically_stretchable = "off",
        width = 450,
        height = 105,
    },
    [constants.style.signal_constants_value_frame] =
    {
      type = "textbox_style",
      horizontally_stretchable = "off",
      vertically_stretchable = "off",
      horizontal_align = "center",
      font = "default",
      size = {80, 28},
      left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},
    },
    [constants.style.signal_constants_inner_frame] =
    {
        type = "frame_style",
        parent = "inside_shallow_frame",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        vertical_align = "center",
        horizontal_align = "left",
        margin = 0,
        padding  = 12,
        width = 0,
        height = 0,

        horizontal_flow_style =
        {
            type = "horizontal_flow_style",
            vertical_align = "center",
            horizontal_align = "left",
            horizontally_stretchable = "on",
            vertically_stretchable = "on",
        },
    },
    [constants.style.signal_inner_frame] =
    {
        type = "frame_style",
        parent = "inside_deep_frame_for_tabs",
        vertical_align = "top",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        horizontally_squashable = "on",
        vertically_squashable = "on",
        padding  = 0
    },
    [constants.style.signal_group_frame] =
    {
        type = "table_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        horizontally_squashable = "on",
        vertically_squashable = "on",
        vertical_spacing = 1,
        horizontal_spacing = 1,
        padding  = 0,
        width = 432,
        graphical_set =
        {
            base =
            {
                position = {17, 0},
                corner_size = 8,
                center = {position = {42, 8}, size = 1},
                top = {},
                left_top = {},
                right_top = {},
                draw_type = "outer"
            },
            shadow = default_inner_shadow
        },
        background_graphical_set =
        {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_vertical_size = 48,
            overall_tiling_vertical_spacing = 24,
            overall_tiling_vertical_padding = 12,
            overall_tiling_horizontal_size = 48,
            overall_tiling_horizontal_spacing = 23,
            overall_tiling_horizontal_padding = 12,
        },
    },
    [constants.style.signal_group_button_frame] =
    {
        type = "button_style",
        parent = "button_with_shadow",
        vertical_align = "top",
        horizontal_align = "left",
        padding  = 6,
        width = 70,
        height = 70
    },
    [constants.style.signal_group_label] =
    {
        type = "label_style",
        vertical_align = "top",
        horizontal_align = "left",
        padding  = 0,
        left_padding = -1,
        top_padding = -1,
        width = 70,
        height = 70
    },
    [constants.style.scroll_pane_with_dark_background] =
    {
        type = "scroll_pane_style",
        extra_padding_when_activated = 0,
        padding = 4,
        graphical_set =
        {
            base =
            {
                position = {17, 0},
                corner_size = 8,
                center = {position = {42, 8}, size = 1},
                top = {},
                left_top = {},
                right_top = {},
                draw_type = "outer"
            },
            shadow = default_inner_shadow
        }
    },
    [constants.style.signal_subgroup_frame] =
    {
        type = "table_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        vertical_spacing = 0,
        horizontal_spacing = 0,
        padding  = 0,
        left_padding = 1
    },
    [constants.style.signal_subgroup_scroll_frame] =
    {
        type = "scroll_pane_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        horizontally_squashable = "off",
        vertically_squashable = "off",
        vertical_spacing = 0,
        horizontal_spacing = 0,
        top_margin = 12,
        left_margin = 12,
        bottom_margin = 12,
        padding  = 0,
        top_padding = -3,
        left_padding = -5,
        width = 412,
        height = 442,
        graphical_set =
        {
            base =
            {
                top =
                {
                    filename = constants.gui_image,
                    position = {12, 0}, size = {1, 24}
                },
                bottom =
                {
                    filename = constants.gui_image,
                    position = {12, 0}, size = {1, 24}
                },
                left =
                {
                    filename = constants.gui_image,
                    position = {0, 12}, size = {24, 1}
                },
                left_top =
                {
                    filename = constants.gui_image,
                    position = {24, 0}, size = 24
                },
                left_bottom =
                {
                    filename = constants.gui_image,
                    position = {24, 0}, size = 24
                },
                right_top =
                {
                    filename = constants.gui_image,
                    position = {24, 0}, size = 24
                },
                right_bottom =
                {
                    filename = constants.gui_image,
                    position = {24, 0}, size = 24
                },
                draw_type = "outer"
            },
            shadow = default_inner_shadow
        },
        background_graphical_set =
        {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_vertical_size = 32,
            overall_tiling_vertical_spacing = 8,
            overall_tiling_vertical_padding = 4,
            overall_tiling_horizontal_size = 32,
            overall_tiling_horizontal_spacing = 8,
            overall_tiling_horizontal_padding = 4,
        },
        vertical_flow_style =
        {
            type = "vertical_flow_style",
            horizontally_stretchable = "off",
            width = 400,
        },
    },
    [constants.style.signal_subgroup_button_frame] =
    {
        type = "button_style",
        parent = "slot_button",
        padding = 0,

        disabled_graphical_set =
        {
            base = {border = 4, position = {80, 736}, size = 80},
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
        }
    },
    [constants.style.signal_subgroup_selected_button_frame] =
    {
        type = "button_style",
        parent = "slot_button",
        padding = 0,

        default_graphical_set =
        {
            base = {border = 4, position = {80, 736}, size = 80},
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
        }
    },
    [constants.style.constant_button_frame] =
    {
        type = "button_style",
        parent = "button_with_shadow",
        horizontal_align = "center",
        vertical_align = "center",
        horizontally_stretchable = "on",

        left_margin = 40,
        right_padding = 12,
        width = 110,
        height = 28
    },
    [constants.style.tasks_frame] =
    {
        type = "frame_style",
        parent = "inside_deep_frame_for_tabs",
        vertical_align = "top",
        horizontal_align = "left",
        vertically_stretchable = "on",

        top_padding  = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,

        width = 364
    },
    [constants.style.conditional_frame] =
    {
        type = "frame_style",
        parent = "dark_frame",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",

        top_padding  = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,

        height = 36
    },
    [constants.style.sub_conditional_frame] =
    {
        type = "frame_style",
        parent = constants.style.conditional_frame,
        left_margin = 36
    },
    [constants.style.group_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        vertical_spacing = 4
    },
    [constants.style.sub_group_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        vertical_spacing = 4,
        height = 0
    },
    [constants.style.conditional_flow_frame] =
    {
        type = "horizontal_flow_style",
        horizontally_stretchable = "off",
        vertically_stretchable = "on",
        vertical_align = "center",
        horizontal_align = "left",
        horizontal_spacing = 4,
        padding = 4,
        height = 36
    },
    [constants.style.conditional_progress_frame] =
    {
        type = "progressbar_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        color = {20, 255, 90, 210},
        other_colors = {},
        padding  = 0,
        bar_width = 36,
        height = 36,
        embed_text_in_bar = false,

        bar =
        {
            base = {position = {68, 0}, corner_size = 8, tint = {100, 255, 100, 0}},
            shadow = default_shadow
        },
        bar_background =
        {
            base = {position = {68, 0}, corner_size = 8},
            shadow = default_shadow
        },
    },
    [constants.style.play_button_frame] =
    {
        type = "button_style",
        vertical_align = "center",
        horizontal_align = "left",
        padding = 0,

        size = {28, 28},
        left_margin = 0,
        top_margin = 0,

        default_graphical_set =
        {
            base = {position = {0, 17}, corner_size = 8},
            glow = default_shadow           
        },
        hovered_graphical_set =
        {
            base = {position = {34, 17}, corner_size = 8},
            glow = default_shadow
        },
        clicked_graphical_set =
        {
            base = {position = {51, 17}, corner_size = 8},
            glow = default_shadow
        },
        left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},

    },
    [constants.style.time_selection_frame] =
    {
      type = "textbox_style",
      horizontal_align = "center",
      font = "default-semibold",
      size = {62, 28},
      left_click_sound = {{ filename = "__core__/sound/gui-menu-small.ogg", volume = 1 }},
    },
    [constants.style.callable_timer_label] =
    {
      type = "label_style",
      vertical_align = "center",
      horizontal_align = "left",
      horizontally_squashable = "on",
      font = "default-semibold",
      left_margin = 5,
      width = 93,
      font_color = {220, 220, 220}
    },
    [constants.style.callable_begining_label_frame] =
    {
      type = "label_style",
      vertical_align = "center",
      horizontal_align = "right",
      horizontally_squashable = "on",
      font = "default-semibold",
      width = 50,
      font_color = {220, 220, 220}
    },
    [constants.style.repeatable_begining_label_frame] =
    {
      type = "label_style",
      vertical_align = "center",
      horizontal_align = "right",
      horizontally_squashable = "on",
      font = "default-semibold",
      width = 120,
      font_color = {220, 220, 220}
    },
    [constants.style.repeatable_end_label_frame] =
    {
        type = "label_style",
        vertical_align = "center",
        horizontal_align = "left",
        font = "default-semibold",
        width = 92,
        font_color = {220, 220, 220}
    },
    [constants.style.close_button_frame] =
    {
        type = "button_style",
        vertical_align = "center",
        horizontal_align = "right",
        padding = 0,
        size = {16, 28},
        left_margin = 0,
        top_margin = 0,

        default_graphical_set =
        {
            base =
            {
                position = {68, 0},
                corner_size = 8,
            }
        },
    },
    [constants.style.scroll_pane] =
    {
        type = "scroll_pane_style",
        parent = constants.style.scroll_pane_with_dark_background,
        vertically_stretchable = "on",
        top_padding  = 5,
        right_padding = 5,
        bottom_padding = 5,
        left_padding = 5,
        width = 364,

        background_graphical_set =
        {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_horizontal_spacing = 8,
            overall_tiling_horizontal_padding = 4,
            overall_tiling_vertical_spacing = 12,
            overall_tiling_vertical_size = 28,
            overall_tiling_vertical_padding = 4
        },
        vertical_flow_style =
        {
            type = "vertical_flow_style",
            horizontally_stretchable = "off",
            width = 342,
            
        },
    },
    [constants.style.task_dropdown_frame] =
    {
        type = "dropdown_style",
        horizontally_stretchable = "on",
        height = 36,

        button_style =
        {
            type = "button_style",
            parent = "button_with_shadow",
            horizontal_align = "left",
            vertical_align = "center",
        },
        icon =
        {
            filename = nil,
            priority = nil,
            size = 32,
            tint = {0, 0, 0, 0}
        },
        list_box_style =
        {
            type = "list_box_style",
            vertical_align = "top",
            horizontal_align = "left",
            horizontally_stretchable = "off",
            maximal_height = 400,

            item_style =
            {
                type = "button_style",
                parent = "list_box_item",
                left_padding = 4,
                right_padding = 4
            },
            scroll_pane_style =
            {
                type = "scroll_pane_style",
                extra_padding_when_activated = 0,
                graphical_set =
                {
                    base =
                    {
                        position = {17, 0},
                        corner_size = 8,
                        scale = 0.75,
                        top_outer_border_shift = 4,
                        bottom_outer_border_shift = -4,
                        left_outer_border_shift = 4,
                        right_outer_border_shift = -4,
                    },
                    shadow = 
                    {
                        position = {200, 128},
                        corner_size = 8,
                        tint = {0, 0, 0, 90},
                        scale = 0.75,
                        draw_type = "inner"
                    },
                }
            }
        }
    },
    [constants.style.subtask_dropdown_frame] =
    {
        type = "dropdown_style",
        parent = constants.style.task_dropdown_frame,
        left_margin = 36
    },
    [constants.style.condition_comparator_dropdown_frame] =
    {
        type = "dropdown_style",
        minimal_width = 0,
        left_padding = 4,
        right_padding = 0,
        width = 64,
        height = 28,

        -- semi-hack redefining the graphical set to put shadow in to glow layer to be on top of the neighbour inset
        button_style =
        {
            type = "button_style",
            parent = "dropdown_button",

            default_graphical_set =
            {
                base = {position = {0, 17}, corner_size = 8},
                glow = default_dirt
            },
            hovered_graphical_set =
            {
                base = {position = {34, 17}, corner_size = 8},
                glow = default_glow
            },
            clicked_graphical_set =
            {
                base = {position = {51, 17}, corner_size = 8},
                glow = default_dirt
            },
            disabled_graphical_set =
            {
                base = {position = {0, 0}, corner_size = 8},
                glow = default_dirt
            },
            selected_graphical_set =
            {
                base = {position = {225, 17}, corner_size = 8},
                glow = default_dirt
            },
            selected_hovered_graphical_set =
            {
                base = {position = {369, 17}, corner_size = 8},
                glow = default_dirt
            },
            selected_clicked_graphical_set =
            {
                base = {position = {352, 17}, corner_size = 8},
                glow = default_dirt
            }
        },
        list_box_style =
        {
            type = "list_box_style",
            
            maximal_height = 400,
            item_style =
            {
                type = "button_style",
                parent = "list_box_item",
                left_padding = 4,
                right_padding = 4
            },
            scroll_pane_style =
            {
                type = "scroll_pane_style",
                padding = 0,
                extra_padding_when_activated = 0,
                graphical_set = {shadow = default_shadow}
            }
        }
    },
    [constants.style.callable_timer_dropdown_frame] =
    {
        type = "dropdown_style",
        parent = constants.style.condition_comparator_dropdown_frame,
        width = 114
    },
    [constants.style.dropdown_overlay_label_frame] =
    {
        type = "label_style",
        font = "default-semibold",
        top_padding = 5,
        font_color = {0, 0, 0},
        hovered_font_color = {249, 168, 56}
    },
    [constants.style.dark_button_frame] =
    {
        type = "button_style",
        parent = "train_schedule_item_select_button",
        font = "very-small-semibold",
        default_font_color = {225, 225, 225},

        width = 28,
        height = 28,
    },
    [constants.style.dark_button_numbers_frame] =
    {
        type = "button_style",
        parent = constants.style.dark_button_frame,
        font = "very-small-semibold",
        vertical_align = "center",
        horizontal_align = "center",
        default_font_color = {225, 225, 225},
        padding = -5,
        width = 28,
        height = 28,
    },
    [constants.style.dark_button_selected_frame] =
    {
        type = "button_style",
        parent = constants.style.dark_button_frame,

        default_font_color = {20, 20, 20},

        default_graphical_set =
        {
            base = {border = 4, position = {162, 738}, size = 76},
            shadow =
            {
                position = {378, 103},
                corner_size = 16,
                top_outer_border_shift = 4,
                bottom_outer_border_shift = -4,
                left_outer_border_shift = 4,
                right_outer_border_shift = -4,
                draw_type = "outer"
            }
        }
    },
    [constants.style.dark_button_selected_numbers_frame] =
    {
        type = "button_style",
        parent = constants.style.dark_button_selected_frame,
        vertical_align = "center",
        horizontal_align = "center",
        padding = -5,
    },
    [constants.style.invisible_frame] =
    {
        type = "button_style",
        padding = 0,
        margin = 0,
        width = 28,
        height = 28,
        default_graphical_set = {},

        horizontal_flow_style =
        {
            type = "horizontal_flow_style",
            horizontal_spacing = 0
        },
        vertical_flow_style =
        {
            type = "vertical_flow_style",
            vertical_spacing = 0
        }
    },
    [constants.style.radio_vertical_flow_frame] =
    {
        type = "vertical_flow_style",
        vertical_align = "center",
        horizontal_align = "left",
        horizontally_stretchable = "on",
        vertically_stretchable = "off",
        vertical_spacing = -4,
        top_margin = -5,
        padding = 0,
        height = 0
    },
    [constants.style.radiobutton_frame] =
    {
        type = "radiobutton_style",
        parent = "radiobutton",
        padding = 0,
        text_padding = 0
    },
    [constants.style.combinator_horizontal_padding_frame] =
    {
        type = "empty_widget_style",
        horizontally_stretchable = "on",
    },
    [constants.style.screen_strech_frame] =
    {
        type = "button_style",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        default_graphical_set = {},
        hovered_graphical_set = {},
        clicked_graphical_set = {},
        left_click_sound = {},
        width = 4000, -- ?
        height = 2400, -- ?
        padding = 0
    }
})