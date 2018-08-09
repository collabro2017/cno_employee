module DedupesHelper

  def dedupe_switch(dedupe)
    data = {
        animated: "true",
        on: "primary",
        off: "primary",
        on_label: "MIN",
        off_label: "MAX",
        loaded: "false"
      }

    is_checked = dedupe.tiebreak == "MIN" ? true : false
    check_box_tag(nil, value = "", checked = is_checked, class: "switch-mini switch-change", data: data)
  end
end
