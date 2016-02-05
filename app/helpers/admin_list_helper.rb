module AdminListHelper
  STATUS_BOOTSTRAP_MAP = {
    :default => "list-status label",

    :article => {
      NewsStory.status_id(:killed)            => "list-status label label-important",
      NewsStory.status_id(:draft)             => "list-status label",
      NewsStory.status_id(:awaiting_rework)   => "list-status label label-info",
      NewsStory.status_id(:awaiting_edits)    => "list-status label label-inverse",
      NewsStory.status_id(:pending)           => "list-status label label-warning",
      NewsStory.status_id(:live)              => "list-status label label-success"
    },

    :types => {
      :published      => "list-status label label-success",
      :pending        => "list-status label label-warning",
      :unpublished    => "list-status label"
    },

    :audio => {
      Audio.status_id(:none)      => "list-status label",
      Audio.status_id(:waiting)   => "list-status label label-warning",
      Audio.status_id(:live)      => "list-status label label-success"
    },

    :pmp => {
      true => "list-status label label-success",
      false => "list-status label"
    }
  }


  def display_link(link)
    link_to content_tag(:i, nil, class: "icon-share-alt"), link, class: "btn"
  end

  #-------------
  # Associations

  # For a polymorphic content association - requires headline and obj_key
  def display_content(content)
    if content &&
    content.respond_to?(:headline) &&
    content.respond_to?(:obj_key)
      s = content.headline
      s += " (" + link_to(content.obj_key, content.admin_edit_path) + ")"
      s.html_safe
    end
  end

  #-------------
  # Attribute Helpers

  # Display the status based on the status's TYPE
  # (eg. published, unpublished, pending...)
  def display_status(status, record)
    content_tag :div, record.status_text, {
      :class => STATUS_BOOTSTRAP_MAP[:types][record.status_type] ||
                STATUS_BOOTSTRAP_MAP[:default]
    }
  end

  # Special helper for displaying Article statuses, which
  # have different colors for each status.
  def display_article_status(status, record)
    content_tag :div, record.status_text, {
      :class => STATUS_BOOTSTRAP_MAP[:article][status]
    }
  end

  def display_pmp_status(status, record)
    content_tag :div, {true => "Published", false => "Unpublished"}[status], {
      :class => STATUS_BOOTSTRAP_MAP[:pmp][status]
    }
  end

  def display_air_status(air_status)
    KpccProgram::PROGRAM_STATUS[air_status]
  end

  def display_audio(audio)
    audio   = Array(audio).first
    status  = audio.try(:status)
    text    = audio.try(:status_text)

    content_tag :div, text || "None", {
      :class => STATUS_BOOTSTRAP_MAP[:audio][status]
    }
  end

  def status_bootstrap_map
    STATUS_BOOTSTRAP_MAP
  end
end
