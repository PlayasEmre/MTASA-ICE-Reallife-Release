				</div>
				<!-- /. PAGE INNER  -->
				<a href="<?=IMPRINT_LINK?>" target="_blank" style="font-size:11px;">Impressum</a> <span style="float:right;">© <a href="https://www.mta-sa.org/user/2368-lars-marcel/" target="_blank">Lars-Marcel</a></span>
			</div>
			<!-- /. PAGE WRAPPER  -->
			
		</div>
		<!-- /. WRAPPER  -->
		
		<!-- SCRIPTS -AT THE BOTOM TO REDUCE THE LOAD TIME-->
		<!-- BOOTSTRAP SCRIPTS -->
		<script src="assets/js/bootstrap.min.js"></script>
		<!-- METISMENU SCRIPTS -->
		<script src="assets/js/jquery.metisMenu.js"></script>
		<!-- DATA TABLE SCRIPTS -->
		<script src="assets/js/dataTables/jquery.dataTables.js"></script>
		<script src="assets/js/dataTables/dataTables.bootstrap.js"></script>		
		<!-- CUSTOM SCRIPTS -->
		<script>
			/*
				Markierungen auf einer Karte setzen, die mit cpKarte()
				erzeugt wurde (siehe usefull.php).

				id      = die ID des Karten-Containers
				punkte  = [[x, y, "Beschriftung"], ...]

				Die Karte selbst ist ein normales Bild - es wird also kein
				GD und kein Server-Aufruf gebraucht.
			*/
			function cpMarker(id, punkte, mitNummern) {
				var ebene = $("#" + id + " .cp-marker");
				if (ebene.length === 0) { return; }
				ebene.empty();

				$.each(punkte, function (i, p) {
					var links = ((parseFloat(p[0]) + 3000) / 6000) * 100;
					var oben  = ((3000 - parseFloat(p[1])) / 6000) * 100;
					if (isNaN(links) || isNaN(oben)) { return; }
					if (links < 0 || links > 100 || oben < 0 || oben > 100) { return; }

					var titel = (p.length > 2 && p[2]) ? String(p[2]) : "";
					var nummer = "";
					if (mitNummern) {
						nummer = '<span style="position:absolute; left:14px; top:-4px; color:#fff; font-size:12px; font-weight:bold; text-shadow:0 0 3px #000, 0 0 3px #000; line-height:1;">' + (i + 1) + '</span>';
					}

					ebene.append(
						'<div style="position:absolute; left:' + links + '%; top:' + oben + '%; width:0; height:0;" title="' + titel.replace(/"/g, '') + '">' +
						'<span style="position:absolute; left:-6px; top:-6px; width:12px; height:12px; border-radius:50%; background:#e03131; border:2px solid #fff; box-shadow:0 0 4px rgba(0,0,0,0.8);"></span>' +
						nummer +
						'</div>'
					);
				});
			}
			$(document).ready(function () {
                $('#dataTables-example').dataTable();
            });
		</script>
		<script src="assets/js/custom.js"></script>
	</body>
</html>