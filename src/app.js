import {__jacJsx, __jacSpawn} from "@jac-client/utils";
import { useState, useEffect } from "react";
function NavBar(currentPage, onNavigate) {
  return __jacJsx("div", {"style": {"background": "linear-gradient(135deg, #E91E63 0%, #F48FB1 100%)", "padding": "20px 0", "boxShadow": "0 2px 10px rgba(0,0,0,0.1)", "marginBottom": "0"}}, [__jacJsx("div", {"style": {"maxWidth": "1200px", "margin": "0 auto", "padding": "0 20px", "display": "flex", "justifyContent": "space-between", "alignItems": "center"}}, [__jacJsx("div", {"style": {"display": "flex", "alignItems": "center", "gap": "15px"}}, [__jacJsx("span", {"style": {"fontSize": "36px"}}, ["🤰"]), __jacJsx("div", {}, [__jacJsx("h1", {"style": {"color": "white", "margin": "0", "fontSize": "28px", "fontWeight": "bold"}}, ["MaternAI"]), __jacJsx("p", {"style": {"color": "rgba(255,255,255,0.9)", "margin": "0", "fontSize": "12px"}}, ["Smart Maternal Health Monitoring"])])]), __jacJsx("div", {"style": {"display": "flex", "gap": "10px"}}, [["home", "dashboard", "symptoms", "about"].map(page => {
    let is_active = currentPage === page;
    return __jacJsx("button", {"key": page, "onClick": () => {
      onNavigate(page);
    }, "style": {"padding": "10px 20px", "background": is_active ? "white" : "rgba(255,255,255,0.2)", "color": is_active ? "#E91E63" : "white", "border": "none", "borderRadius": "25px", "cursor": "pointer", "fontWeight": "bold", "fontSize": "14px", "transition": "all 0.3s"}}, [page.toUpperCase()]);
  })])])]);
}
function HomePage(onNavigate) {
  return __jacJsx("div", {"style": {"background": "linear-gradient(180deg, #FFF0F5 0%, #FFFFFF 100%)", "minHeight": "calc(100vh - 100px)"}}, [__jacJsx("div", {"style": {"maxWidth": "1200px", "margin": "0 auto", "padding": "60px 20px", "textAlign": "center"}}, [__jacJsx("div", {"style": {"marginBottom": "60px"}}, [__jacJsx("div", {"style": {"fontSize": "80px", "marginBottom": "20px"}}, ["🤰"]), __jacJsx("h1", {"style": {"fontSize": "48px", "color": "#E91E63", "marginBottom": "20px", "fontWeight": "bold"}}, ["Welcome to MaternAI"]), __jacJsx("p", {"style": {"fontSize": "24px", "color": "#666", "marginBottom": "40px", "lineHeight": "1.6"}}, ["AI-Powered Maternal Health Monitoring", __jacJsx("br", {}, []), "Empowering healthier pregnancies through intelligent technology"]), __jacJsx("button", {"onClick": () => {
    onNavigate("dashboard");
  }, "style": {"padding": "18px 40px", "background": "linear-gradient(135deg, #E91E63, #F48FB1)", "color": "white", "border": "none", "borderRadius": "30px", "fontSize": "18px", "fontWeight": "bold", "cursor": "pointer", "boxShadow": "0 4px 15px rgba(233,30,99,0.3)", "transition": "transform 0.3s"}}, ["Get Started →"])]), __jacJsx("div", {"style": {"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(280px, 1fr))", "gap": "30px", "marginTop": "60px"}}, [[{"icon": "\ud83d\udcca", "title": "Real-Time Monitoring", "desc": "Track vital signs and health metrics throughout your pregnancy journey"}, {"icon": "\ud83e\udde0", "title": "AI Risk Analysis", "desc": "Advanced AI algorithms detect potential risks and provide early warnings"}, {"icon": "\ud83e\ude7a", "title": "Symptom Checker", "desc": "Instant AI-powered assessment of pregnancy symptoms with expert guidance"}, {"icon": "\ud83d\udcf1", "title": "Easy to Use", "desc": "Simple, intuitive interface designed for expecting mothers"}].map(feature => {
    return __jacJsx("div", {"style": {"background": "white", "padding": "40px 30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)", "transition": "transform 0.3s"}}, [__jacJsx("div", {"style": {"fontSize": "48px", "marginBottom": "20px"}}, [feature["icon"]]), __jacJsx("h3", {"style": {"color": "#E91E63", "fontSize": "20px", "marginBottom": "15px", "fontWeight": "bold"}}, [feature["title"]]), __jacJsx("p", {"style": {"color": "#666", "fontSize": "15px", "lineHeight": "1.6"}}, [feature["desc"]])]);
  })]), __jacJsx("div", {"style": {"marginTop": "80px", "padding": "40px", "background": "linear-gradient(135deg, #E91E63, #F48FB1)", "borderRadius": "20px", "color": "white"}}, [__jacJsx("div", {"style": {"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(200px, 1fr))", "gap": "30px"}}, [[{"num": "4+", "label": "AI Agents"}, {"num": "24/7", "label": "Monitoring"}, {"num": "100%", "label": "Secure"}, {"num": "\u221e", "label": "Care"}].map(stat => {
    return __jacJsx("div", {}, [__jacJsx("div", {"style": {"fontSize": "42px", "fontWeight": "bold", "marginBottom": "10px"}}, [stat["num"]]), __jacJsx("div", {"style": {"fontSize": "18px", "opacity": "0.9"}}, [stat["label"]])]);
  })])])])]);
}
function DashboardPage(patientId) {
  let [data, setData] = useState(null);
  let [loading, setLoading] = useState(false);
  function refreshData() {
    setLoading(true);
    let result = !root.dashboard_reporter({patient_id: patientId});
    setLoading(false);
    if (result.reports && len(result.reports) > 0) {
      setData(result.reports[0]);
    }
  }
  function addMetric(mtype, val, unit) {
    !root.recorder({patient_id: patientId, metric_type: mtype, value: val, unit: unit});
    refreshData();
  }
  function runAnalysis() {
    setLoading(true);
    !root.risk_analyzer({patient_id: patientId});
    setLoading(false);
    refreshData();
  }
  useEffect(() => {
    refreshData();
  }, []);
  if (!data) {
    return __jacJsx("div", {"style": {"textAlign": "center", "padding": "100px 20px", "minHeight": "calc(100vh - 100px)"}}, [__jacJsx("div", {"style": {"fontSize": "64px", "marginBottom": "20px"}}, ["⏳"]), __jacJsx("h2", {"style": {"color": "#666"}}, ["Loading your health dashboard..."])]);
  }
  let patient = data.get("patient", {});
  let metrics = data.get("metrics", []);
  let risks = data.get("risks", []);
  let stats = data.get("stats", {});
  let risk_display = null;
  if (len(risks) === 0) {
    risk_display = __jacJsx("div", {"style": {"textAlign": "center", "padding": "40px", "color": "#999"}}, [__jacJsx("div", {"style": {"fontSize": "64px", "marginBottom": "15px"}}, ["✨"]), __jacJsx("p", {"style": {"fontSize": "18px"}}, ["No analysis yet. Click 'Run Analysis' to start AI health assessment."])]);
  } else {
    risk_display = __jacJsx("div", {}, [risks.map(r => {
      let colors = {"Low": "#4CAF50", "Medium": "#FF9800", "High": "#F44336"};
      let bg_colors = {"Low": "#E8F5E9", "Medium": "#FFF3E0", "High": "#FFEBEE"};
      let sev = r.get("severity", "Low");
      return __jacJsx("div", {"style": {"background": bg_colors.get(sev, "#F5F5F5"), "padding": "25px", "borderRadius": "12px", "borderLeft": "6px solid " + colors.get(sev, "#999"), "marginBottom": "20px"}}, [__jacJsx("div", {"style": {"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "15px"}}, [__jacJsx("span", {"style": {"padding": "6px 15px", "background": colors.get(sev, "#999"), "color": "white", "borderRadius": "20px", "fontSize": "14px", "fontWeight": "bold"}}, [sev.toUpperCase(), " RISK"])]), __jacJsx("p", {"style": {"fontSize": "16px", "color": "#333", "marginBottom": "15px", "lineHeight": "1.6"}}, [__jacJsx("strong", {}, ["Assessment:"]), " ", r.get("summary")]), __jacJsx("p", {"style": {"fontSize": "15px", "color": "#666", "margin": "0", "lineHeight": "1.6"}}, [__jacJsx("strong", {}, ["Recommendation:"]), " ", r.get("recommendation")])]);
    })]);
  }
  return __jacJsx("div", {"style": {"background": "#F5F5F5", "minHeight": "calc(100vh - 100px)", "padding": "40px 20px"}}, [__jacJsx("div", {"style": {"maxWidth": "1200px", "margin": "0 auto"}}, [__jacJsx("div", {"style": {"background": "white", "padding": "30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)", "marginBottom": "30px", "display": "flex", "alignItems": "center", "gap": "30px"}}, [__jacJsx("div", {"style": {"width": "100px", "height": "100px", "borderRadius": "50%", "background": "linear-gradient(135deg, #E91E63, #F48FB1)", "display": "flex", "alignItems": "center", "justifyContent": "center", "fontSize": "48px", "color": "white", "fontWeight": "bold", "boxShadow": "0 4px 15px rgba(233,30,99,0.3)"}}, [patient.get("name", "P")[0]]), __jacJsx("div", {"style": {"flex": "1"}}, [__jacJsx("h2", {"style": {"margin": "0 0 10px 0", "fontSize": "32px", "color": "#333"}}, [patient.get("name", "Patient")]), __jacJsx("div", {"style": {"display": "flex", "gap": "30px", "color": "#666", "fontSize": "16px"}}, [__jacJsx("span", {}, ["👤 Age: ", patient.get("age")]), __jacJsx("span", {}, ["📅 Week: ", patient.get("week"), "/40"]), __jacJsx("span", {}, ["🩸 Blood: ", patient.get("blood_type")]), __jacJsx("span", {}, ["📧 ", patient.get("email")])])])]), __jacJsx("div", {"style": {"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(250px, 1fr))", "gap": "20px", "marginBottom": "30px"}}, [[{"icon": "\ud83d\udcca", "label": "Total Metrics", "value": stats.get("total_metrics", 0), "color": "#2196F3"}, {"icon": "\u26a0\ufe0f", "label": "Abnormal", "value": stats.get("abnormal_metrics", 0), "color": "#FF9800"}, {"icon": "\ud83e\ude7a", "label": "Symptoms", "value": stats.get("total_symptoms", 0), "color": "#9C27B0"}].map(card => {
    return __jacJsx("div", {"style": {"background": "white", "padding": "25px", "borderRadius": "15px", "boxShadow": "0 2px 10px rgba(0,0,0,0.06)", "display": "flex", "alignItems": "center", "gap": "20px"}}, [__jacJsx("div", {"style": {"fontSize": "40px", "width": "60px", "height": "60px", "borderRadius": "12px", "background": card["color"] + "20", "display": "flex", "alignItems": "center", "justifyContent": "center"}}, [card["icon"]]), __jacJsx("div", {}, [__jacJsx("div", {"style": {"fontSize": "32px", "fontWeight": "bold", "color": card["color"]}}, [card["value"]]), __jacJsx("div", {"style": {"color": "#999", "fontSize": "14px"}}, [card["label"]])])]);
  })]), __jacJsx("div", {"style": {"background": "white", "padding": "30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)", "marginBottom": "30px", "border": "2px solid #E91E63"}}, [__jacJsx("div", {"style": {"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "25px"}}, [__jacJsx("h3", {"style": {"margin": "0", "fontSize": "24px", "color": "#E91E63", "display": "flex", "alignItems": "center", "gap": "10px"}}, [__jacJsx("span", {}, ["🧠"]), " AI Risk Analysis"]), __jacJsx("button", {"onClick": runAnalysis, "disabled": loading, "style": {"padding": "12px 30px", "background": "linear-gradient(135deg, #E91E63, #F48FB1)", "color": "white", "border": "none", "borderRadius": "25px", "fontSize": "16px", "fontWeight": "bold", "cursor": loading ? "not-allowed" : "pointer", "opacity": loading ? "0.6" : "1", "boxShadow": "0 4px 15px rgba(233,30,99,0.3)"}}, [loading ? "\ud83d\udd04 Analyzing..." : "\ud83e\udde0 Run Analysis"])]), risk_display]), __jacJsx("div", {"style": {"background": "white", "padding": "30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)"}}, [__jacJsx("h3", {"style": {"fontSize": "20px", "marginBottom": "20px", "color": "#333"}}, ["Quick Actions (Simulation)"]), __jacJsx("div", {"style": {"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(200px, 1fr))", "gap": "15px"}}, [__jacJsx("button", {"onClick": () => {
    addMetric("BP Systolic", 145.0, "mmHg");
  }, "style": {"padding": "15px", "background": "#FFEBEE", "color": "#D32F2F", "border": "1px solid #FFCDD2", "borderRadius": "10px", "cursor": "pointer", "fontWeight": "bold"}}, ["🚨 Simulate High BP"]), __jacJsx("button", {"onClick": () => {
    addMetric("Glucose", 150.0, "mg/dL");
  }, "style": {"padding": "15px", "background": "#FFF3E0", "color": "#E65100", "border": "1px solid #FFE0B2", "borderRadius": "10px", "cursor": "pointer", "fontWeight": "bold"}}, ["⚠️ Simulate High Glucose"]), __jacJsx("button", {"onClick": () => {
    addMetric("BP Systolic", 110.0, "mmHg");
  }, "style": {"padding": "15px", "background": "#E8F5E9", "color": "#2E7D32", "border": "1px solid #C8E6C9", "borderRadius": "10px", "cursor": "pointer", "fontWeight": "bold"}}, ["✅ Simulate Normal Vitals"])])])])]);
}
function SymptomPage(patientId) {
  let [selectedSymptoms, setSymptoms] = useState([]);
  let [results, setResults] = useState(null);
  let [loading, setLoading] = useState(false);
  let symptomList = ["Severe Headache", "Vaginal Bleeding", "Decreased Fetal Movement", "Swelling", "Back Pain", "Fatigue", "Nausea", "Vision Changes"];
  function toggleSymptom(sym) {
    if (sym in selectedSymptoms) {
      let new_list = [];
      for (const s of selectedSymptoms) {
        if (s !== sym) {
          new_list.append(s);
        }
      }
      setSymptoms(new_list);
    } else {
      new_list = [];
      for (const s of selectedSymptoms) {
        new_list.append(s);
      }
      new_list.append(sym);
      setSymptoms(new_list);
    }
  }
  function checkSymptoms() {
    setLoading(true);
    let res = !root.symptom_checker({patient_id: patientId, symptoms: selectedSymptoms});
    setLoading(false);
    setResults(res.reports[0].get("results", []));
  }
  let results_display = null;
  if (results) {
    results_display = __jacJsx("div", {"style": {"background": "white", "padding": "30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)"}}, [__jacJsx("h3", {"style": {"marginBottom": "20px"}}, ["Analysis Results"]), results.map(res => {
      let color = res["severity"] === "High" ? "#F44336" : res["severity"] === "Medium" ? "#FF9800" : "#4CAF50";
      return __jacJsx("div", {"style": {"marginBottom": "20px", "padding": "20px", "borderLeft": "5px solid " + color, "background": "#FAFAFA", "borderRadius": "8px"}}, [__jacJsx("div", {"style": {"display": "flex", "justifyContent": "space-between", "marginBottom": "10px"}}, [__jacJsx("strong", {"style": {"fontSize": "18px"}}, [res["symptom"]]), __jacJsx("span", {"style": {"color": color, "fontWeight": "bold"}}, [res["severity"].toUpperCase(), " PRIORITY"])]), __jacJsx("p", {"style": {"margin": "0", "color": "#666"}}, [res["description"]])]);
    })]);
  }
  return __jacJsx("div", {"style": {"background": "#F5F5F5", "minHeight": "calc(100vh - 100px)", "padding": "40px 20px"}}, [__jacJsx("div", {"style": {"maxWidth": "800px", "margin": "0 auto"}}, [__jacJsx("h2", {"style": {"textAlign": "center", "marginBottom": "40px", "fontSize": "32px", "color": "#333"}}, ["AI Symptom Checker"]), __jacJsx("div", {"style": {"background": "white", "padding": "30px", "borderRadius": "20px", "boxShadow": "0 4px 20px rgba(0,0,0,0.08)", "marginBottom": "30px"}}, [__jacJsx("h3", {"style": {"marginBottom": "20px"}}, ["What are you feeling?"]), __jacJsx("div", {"style": {"display": "grid", "gridTemplateColumns": "repeat(auto-fill, minmax(200px, 1fr))", "gap": "15px", "marginBottom": "30px"}}, [symptomList.map(sym => {
    let isSelected = sym in selectedSymptoms;
    return __jacJsx("button", {"onClick": () => {
      toggleSymptom(sym);
    }, "style": {"padding": "15px", "background": isSelected ? "#E91E63" : "#F5F5F5", "color": isSelected ? "white" : "#333", "border": "none", "borderRadius": "10px", "cursor": "pointer", "transition": "all 0.2s", "fontWeight": "bold"}}, [sym]);
  })]), __jacJsx("button", {"onClick": checkSymptoms, "disabled": loading || len(selectedSymptoms) === 0, "style": {"width": "100%", "padding": "15px", "background": "linear-gradient(135deg, #E91E63, #F48FB1)", "color": "white", "border": "none", "borderRadius": "30px", "fontSize": "18px", "fontWeight": "bold", "cursor": loading || len(selectedSymptoms) === 0 ? "not-allowed" : "pointer", "opacity": len(selectedSymptoms) === 0 ? "0.5" : "1"}}, [loading ? "Checking Symptoms..." : "Check Symptoms"])]), results_display])]);
}
function app() {
  let [currentPage, setPage] = useState("home");
  let [patientId, setPatientId] = useState("Sarah Johnson");
  let content = null;
  if (currentPage === "home") {
    content = __jacJsx(HomePage, {"onNavigate": setPage}, []);
  } else if (currentPage === "dashboard") {
    content = __jacJsx(DashboardPage, {"patientId": patientId}, []);
  } else if (currentPage === "symptoms") {
    content = __jacJsx(SymptomPage, {"patientId": patientId}, []);
  } else {
    content = __jacJsx("div", {"style": {"padding": "50px", "textAlign": "center"}}, [__jacJsx("h2", {}, ["About MaternAI"]), __jacJsx("p", {}, ["Hackathon Project Submission"]), __jacJsx("p", {}, ["Built with Jaseci + Jac + React"])]);
  }
  return __jacJsx("div", {"style": {"fontFamily": "'Segoe UI', sans-serif"}}, [__jacJsx(NavBar, {"currentPage": currentPage, "onNavigate": setPage}, []), content]);
}
export { DashboardPage, HomePage, NavBar, SymptomPage, app };
