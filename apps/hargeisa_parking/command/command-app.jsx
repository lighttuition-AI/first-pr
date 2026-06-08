/* global React */
/* HPark Command — app shell & routing */
const { useState: useStateCApp, useEffect: useEffectCApp } = React;

const PAGE_META = {
  'Dashboard': ['Operations overview', 'Hargeisa · ' + new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })],
  'Live map': ['Live map', 'Real-time parking & officer positions'],
  'Officers': ['Officers', 'Enforcement team performance & coverage'],
  'Zones': ['Zones & districts', 'Compliance and revenue across 9 districts'],
  'Vehicles': ['Vehicles', 'Registry, permits & bulk data import'],
  'Appeals': ['Appeals review', 'Adjudicate driver challenges'],
  'Reports': ['Reports', 'Analytics on citations, payments & revenue'],
};

function CommandApp() {
  const [page, setPage] = useStateCApp('Dashboard');
  useEffectCApp(() => { if (window.lucide) window.lucide.createIcons(); }, [page]);
  const [title, sub] = PAGE_META[page];

  let body;
  if (page === 'Dashboard') body = <window.CmdDashboard />;
  else if (page === 'Live map') body = <window.CmdLiveMapPage />;
  else if (page === 'Officers') body = <window.CmdOfficersPage />;
  else if (page === 'Zones') body = <window.CmdZonesPage />;
  else if (page === 'Vehicles') body = <window.CmdVehiclesPage />;
  else if (page === 'Appeals') body = <window.CmdAppealsPage />;
  else if (page === 'Reports') body = <window.CmdReportsPage />;

  return (
    <div style={{ display: 'flex', width: '100%', height: '100%', minHeight: 0 }}>
      <window.CmdSidebar active={page} onNav={setPage} />
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', height: '100%', overflow: 'hidden' }}>
        <window.CmdTopbar title={title} sub={sub} />
        <div style={{ flex: 1, overflow: 'auto', padding: 28 }}>
          {body}
        </div>
      </div>
    </div>
  );
}

window.CommandApp = CommandApp;
