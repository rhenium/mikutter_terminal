require "gtk2"
require "vte"

Plugin.create :mikutter_terminal do
  terminal_box_class = Class.new(Gtk::HBox) do
    attr_reader :terminal, :scrollbar
    def initialize
      super

      @terminal = Vte::Terminal.new
      @terminal.fork_command(argv: [ENV["SHELL"] || "sh"])

      @scrollbar = Gtk::VScrollbar.new(@terminal.adjustment)

      self.add(@terminal).add(@scrollbar)
    end

    def active
      get_ancestor(Gtk::Window).set_focus(@terminal) if get_ancestor(Gtk::Window)
    end
  end

  command(:open_terminal,
          name: "端末を開く",
          condition: ->_ { true },
          role: :pane) do
    box = terminal_box_class.new

    tab(:terminal, "端") do
      box.terminal.signal_connect("child-exited") { self.destroy }

      temporary_tab
      nativewidget box
      active!
    end
  end
end
