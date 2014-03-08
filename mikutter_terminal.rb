require "gtk2"
require "vte"

Plugin.create :mikutter_terminal do
  command(:open_terminal,
          name: "端末を開く",
          condition: ->_ { true },
          role: :pane) do
    terminal = Vte::Terminal.new
    terminal.fork_command(argv: [ENV["SHELL"] || "sh"])
    scroll = Gtk::VScrollbar.new(terminal.adjustment)

    tab(:terminal, "端") do
      terminal.signal_connect("child-exited") { self.destroy }

      temporary_tab
      nativewidget Gtk::HBox.new.add(terminal).add(scroll)
      active!
    end
  end
end
