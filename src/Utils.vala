public class Utils : GLib.Object {
    public string INBOX_STRING = _("Inbox");
    public string TODAY_STRING = _("Today");
    public string UPCOMING_STRING = _("Upcoming");
    public string TOMORROW_STRING = _("Tomorrow");
    public string NONE_STRING = _("None");
    public string NOTIFICATIONS_STRING = _("Notifications");
    public string LABELS_STRING = _("Labels");
    public string MOVE_STRING = _("Move");
    public string TODO_MOVED_STRING = _("to-do moved out of the");
    public string BACK_STRING = _("Move");
    public string DOUBLE_STRING = _("Double click");
    public string TRIPLE_STRING = _("Triple click");
    public string BADGE_COUNT_STRING = _("Badge Count");
    public string START_PAGE_STRING = _("Start Page");
    public string QUICK_SAVE_STRING = _("Quick save");

    public void create_dir_with_parents (string dir) {
        string path = Environment.get_home_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }

    public string convert_invert (string hex) {
        var gdk_white = Gdk.RGBA ();
        gdk_white.parse ("#fff");

        var gdk_black = Gdk.RGBA ();
        gdk_black.parse ("#000");

        var gdk_bg = Gdk.RGBA ();
        gdk_bg.parse (hex);

        var contrast_white = contrast_ratio (
            gdk_bg,
            gdk_white
        );

        var contrast_black = contrast_ratio (
            gdk_bg,
            gdk_black
        );

        var fg_color = "#fff";

        // NOTE: We cheat and add 3 to contrast when checking against black,
        // because white generally looks better on a colored background
        if (contrast_black > (contrast_white + 3)) {
            fg_color = "#000";
        }

        return fg_color;
    }

    private double contrast_ratio (Gdk.RGBA bg_color, Gdk.RGBA fg_color) {
        var bg_luminance = get_luminance (bg_color);
        var fg_luminance = get_luminance (fg_color);

        if (bg_luminance > fg_luminance) {
            return (bg_luminance + 0.05) / (fg_luminance + 0.05);
        }

        return (fg_luminance + 0.05) / (bg_luminance + 0.05);
    }

    private double get_luminance (Gdk.RGBA color) {
        var red = sanitize_color (color.red) * 0.2126;
        var green = sanitize_color (color.green) * 0.7152;
        var blue = sanitize_color (color.blue) * 0.0722;

        return (red + green + blue);
    }

    private double sanitize_color (double color) {
        if (color <= 0.03928) {
            return color / 12.92;
        }

        return Math.pow ((color + 0.055) / 1.055, 2.4);
    }

    public string rgb_to_hex_string (Gdk.RGBA rgba) {
        string s = "#%02x%02x%02x".printf(
            (uint) (rgba.red * 255),
            (uint) (rgba.green * 255),
            (uint) (rgba.blue * 255));
        return s;
    }

    public bool is_label_repeted (Gtk.FlowBox flowbox, int id) {
        foreach (Gtk.Widget element in flowbox.get_children ()) {
            var child = element as Widgets.LabelChild;
            if (child.label.id == id) {
                return true;
            }
        }

        return false;
    }

    public bool is_empty (Gtk.FlowBox flowbox) {
        int l = 0;
        foreach (Gtk.Widget element in flowbox.get_children ()) {
            l = l + 1;
        }

        if (l <= 0) {
            return true;
        } else {
            return false;
        }
    }

    public bool is_listbox_empty (Gtk.ListBox listbox) {
        int l = 0;
        foreach (Gtk.Widget element in listbox.get_children ()) {
            var item = element as Widgets.TaskRow;

            if (item.task.checked == 0) {
                l = l + 1;
            }
        }

        if (l <= 0) {
            return true;
        } else {
            return false;
        }
    }

    public bool is_task_repeted (Gtk.ListBox listbox, int id) {
        foreach (Gtk.Widget element in listbox.get_children ()) {
            var item = element as Widgets.TaskRow;

            if (id == item.task.id) {
                return true;
            }
        }

        return false;
    }

    public bool is_tomorrow (GLib.DateTime date_1) {
        var date_2 = new GLib.DateTime.now_local ().add_days (1);
        return date_1.get_day_of_year () == date_2.get_day_of_year () && date_1.get_year () == date_2.get_year ();
    }

    public bool is_today (GLib.DateTime date_1) {
        var date_2 = new GLib.DateTime.now_local ();
        return date_1.get_day_of_year () == date_2.get_day_of_year () && date_1.get_year () == date_2.get_year ();
    }

    public bool is_upcoming (GLib.DateTime date) {
        if (is_today (date)) {
            return false;
        } else {
            return true;
        }
    }

    public string first_letter_to_up (string text) {
        string l = text.substring (0, 1);
        return l.up () + text.substring (1);
    }
}
