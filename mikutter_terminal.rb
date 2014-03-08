require "gtk2"
require "vte"

Plugin.create :mikutter_terminal do
  UserConfig[:mikutter_terminal_font] ||= "monospace 12"

  terminal_box_class = Class.new(Gtk::HBox) do
    attr_reader :terminal, :scrollbar
    def initialize
      super

      @terminal = Vte::Terminal.new
      @terminal.set_font(UserConfig[:mikutter_terminal_font])
      @terminal.fork_command(argv: [ENV["SHELL"] || "sh"])
      set_context_menu @terminal

      @scrollbar = Gtk::VScrollbar.new(@terminal.adjustment)

      self.add(@terminal).add(@scrollbar)
    end

    def active
      get_ancestor(Gtk::Window).set_focus(@terminal) if get_ancestor(Gtk::Window)
    end

    private
    def set_context_menu(widget)
      widget.signal_connect("button-press-event") do |this, event|
        if event.button == 3
          contextmenu = []

          contextmenu << ["バッファをクリア",
                          ->(x) { true },
                          ->(x) { widget.reset(true, true) }]
          contextmenu << ["クリップボードにコピー",
                          ->(x) { widget.has_selection? },
                          ->(x) { widget.copy_clipboard }]
          contextmenu << ["クリップボードから貼り付け",
                          ->(x) { true },
                          ->(x) { widget.paste_clipboard }]

          Gtk::ContextMenu.new(*contextmenu).popup(widget, widget)
        end
      end
    end
  end

  command(:open_terminal,
          name: "端末を開く",
          condition: ->_ { true },
          role: :pane) do
    box = terminal_box_class.new

    tab(:"terminal_#{Time.now.to_i}", "端") do
      box.terminal.signal_connect("child-exited") { self.destroy }

      temporary_tab
      nativewidget box
      active!
    end
  end

  settings "端末" do
    font "フォント", :mikutter_terminal_font
  end
end
