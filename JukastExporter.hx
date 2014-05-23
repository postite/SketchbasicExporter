class JukastExporter extends HTMLExporter
{
	public function new()
	{
		super();

		// /drawable(@dpi)/nomArtboard_image_comportement(bouton?)_state_

		// /drawable_hxdpi/historique(_button_jaimepas_up_en).png
		// /drawable_hxdpi/historique_button_jaimepas_clicked_en.png
		// /drawable_hxdpi/historique_button_jaimepas_hover_en.png

		// /drawable_hxdpi/common_button_jaimepas_hover.png


	}

	static public function main()
  {
		var app = new JukastExporter extends BasicExporter();
	}
}