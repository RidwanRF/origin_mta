addEventHandler ( "onClientResourceStart", resourceRoot,
	function ()
		txd = engineLoadTXD ( "rally.txd" ); 
		engineImportTXD ( txd, 494 ); 

		dff = engineLoadDFF ( "rally.dff" );
		engineReplaceModel ( dff, 494 ); 
	end
); 