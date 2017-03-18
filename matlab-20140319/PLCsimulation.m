function varargout = PLCsimulation(varargin)
% PLCSIMULATION M-file for PLCsimulation.fig
%      PLCSIMULATION, by itself, creates a new PLCSIMULATION or raises the
%      existing
%      singleton*.
%
%      H = PLCSIMULATION returns the handle to a new PLCSIMULATION or the handle to
%      the existing singleton*.
%
%      PLCSIMULATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLCSIMULATION.M with the given input arguments.
%
%      PLCSIMULATION('Property','Value',...) creates a new PLCSIMULATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NoiseSimulator_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PLCsimulation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PLCsimulation

% Last Modified by GUIDE v2.5 24-May-2013 10:51:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PLCsimulation_OpeningFcn, ...
                   'gui_OutputFcn',  @PLCsimulation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PLCsimulation is made visible.
function PLCsimulation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PLCsimulation (see VARARGIN)

% Choose default command line output for PLCsimulation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PLCsimulation wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global Nnar Npisp Npinp Nran Nback t_sim L;
Nnar=0;Npisp=0;Npinp=0;Nran=0;Nback=0;
set(handles.radiobutton_Nnar_default,'Value',1);%窄带噪声选中默认
set(handles.radiobutton_narrow_day,'Value',1);%窄带噪声选中默认白天
set(handles.radiobutton_Nrandom_Default,'Value',1);%随机脉冲噪声选中默认
set(handles.radiobutton_Nback_Default,'Value',1);%有色背景噪声选中默认
set(handles.radiobutton_Npiap_Default,'Value',1);%异步工频噪声选中默认
set(handles.radiobutton_Npisp_Default,'Value',1);%同步工频噪声选中默认

t_s=1/(6*10^7);
t_sim=0:t_s:0.02;
L=length(t_sim);%仿真长度0.02s,采样间隔按1/60M，产生的噪声长度就相当于对是及噪声的采样了

function mutual_exclude(off)
set(off,'Value',0)


% --- Outputs from this function are returned to the command line.
function varargout = PLCsimulation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton_Nnarrow.
function togglebutton_Nnarrow_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Nnarrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
global Nnar Fnar Pnar fr t_sim is_narrow;
Nnar=0;Fnar=0;Pnar=0;fr=0;is_narrow=0;
if get(hObject,'Value')==get(hObject,'Max')%窄带噪声按钮按下
v_narrow_default=get(handles.radiobutton_Nnar_default,'Value');%得到default单选按钮的值
v_narrow_customer=get(handles.radiobutton_Nnar_Custom,'Value');%得到自定义单选按钮的值
nShort=fix(get(handles.slider_Nnarrow_SW,'Value'));%得到用户输入的短波电台数量的值
nMiddle=fix(get(handles.slider_Nnarrow_MW,'Value'));%得到用户输入的中波电台数量的值

v_narrow_day=0;%默认是白天
if get(handles.radiobutton_narrow_day,'Value')==1
    v_narrow_day=0;
end
if get(handles.radiobutton_narrow_night,'Value')==1
    v_narrow_day=1;
end

if  (v_narrow_default==1)
    [Nnar,Fnar,Pnar,fr]=noise_narrow(0,v_narrow_day);
    is_narrow=1;
    axes(handles.axes2);
    plot(t_sim,Nnar);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fnar);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pnar);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
    %set(gca,'XTick',[]);
    %set(gca,'YTick',[]);
elseif  (v_narrow_customer==1)
    [Nnar,Fnar,Pnar,fr]=noise_narrow(1,v_narrow_day,nShort,nMiddle);
    is_narrow=1;
    axes(handles.axes2);
    plot(t_sim,Nnar);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fnar);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pnar);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
else
    is_narrow=0;
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
end
% timewave(title,t,Nnar)
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Nnarrow


% --- Executes on button press in radiobutton_Nnar_default.
function radiobutton_Nnar_default_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nnar_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nnar_default
%function varargout=radiobutton_Nnar_default_Callback(h,eventdata,handles,varargin)
off=[handles.radiobutton_Nnar_Custom];
mutual_exclude(off);


% --- Executes on button press in radiobutton_Nnar_Custom.
function radiobutton_Nnar_Custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nnar_Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nnar_Custom
%function varargout=radiobutton_Nnar_Custom_Callback(h,eventdata,handles,varargin)
off=[handles.radiobutton_Nnar_default];
mutual_exclude(off)


% --- Executes during object creation, after setting all properties.
function slider_Nnarrow_SW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Nnarrow_SW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Nnarrow_SW_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Nnarrow_SW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit3,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Nnarrow_MW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Nnarrow_MW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Nnarrow_MW_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Nnarrow_MW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit4,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in togglebutton_SO.
function togglebutton_SO_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_SO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_SO
off=[handles.togglebutton_SC];
mutual_exclude(off)
if get(hObject,'Value')==get(hObject,'Min')
    axes(handles.axes2);
    cla;
end

% --- Executes on button press in togglebutton_SC.
function togglebutton_SC_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_SC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
% Hint: get(hObject,'Value') returns toggle state of togglebutton_SC
global is_narrow is_rand is_colord is_nsyn is_syn Nnar Nran Nback Npinp Npisp L t_sim;
fs=6*10^7;

if get(hObject,'Value')==get(hObject,'Max')
    sum=zeros(1,L);
if is_narrow==1
   sum=sum+Nnar;
end
if is_rand==1
    sum=sum+Nran;
end
if is_colord==1
    sum=sum+Nback;
end
if is_nsyn==1
    sum=sum+Npinp;
end
if is_syn==1
    sum=sum+Npisp;
end


    axes(handles.axes2);
    plot(t_sim,sum);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    
    [F,fr]=freqspec(sum,fs);
    axes(handles.axes12);
    plot(fr,F);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    
    Pxx = 1/L * F.*conj(F);
    axes(handles.axes13);
    plot(fr,Pxx);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end

% --- Executes on button press in radiobutton_SO_Nnarrow.
function radiobutton_SO_Nnarrow_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SO_Nnarrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SO_Nnarrow
off=[handles.radiobutton_SO_Npisp,handles.radiobutton_SO_Npiap,handles.radiobutton_SO_Nrandom,handles.radiobutton_SO_Nback];
mutual_exclude(off)
global N F P t
N=0;F=0;P=0;t=0;
if get(handles.togglebutton_Nnarrow,'Value')==get(handles.togglebutton_Nnarrow,'Max')%缺点,是不能在原来状态下有反映,因为用的是回调函数而没有用switch判断来做出反应
if get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')
if get(hObject,'Value')==get(hObject,'Max')
    global Tname N F P Nnar Fnar Pnar tnar t
    Tname='窄带噪声';
    N=Nnar;F=Fnar;P=Pnar;t=tnar;
end
end
end

% --- Executes on button press in radiobutton_SO_Npisp.
function radiobutton_SO_Npisp_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SO_Npisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SO_Npisp
off=[handles.radiobutton_SO_Nnarrow,handles.radiobutton_SO_Npiap,handles.radiobutton_SO_Nrandom,handles.radiobutton_SO_Nback];
mutual_exclude(off)
global N F P t
N=0;F=0;P=0;t=0;
if get(handles.togglebutton_Npisp,'Value')==get(handles.togglebutton_Npisp,'Max')%缺点,是不能在原来状态下有反映,因为用的是回调函数而没有用switch判断来做出反应
if get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')
if get(hObject,'Value')==get(hObject,'Max')
    global Tname N F P Npisp Fpisp Ppisp tpisp t
    Tname='同步工频周期脉冲噪声.';
    N=Npisp;F=Fpisp;P=Ppisp;t=tpisp;
end
end
end

% --- Executes on button press in radiobutton_SO_Npiap.
function radiobutton_SO_Npiap_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SO_Npiap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SO_Npiap
off=[handles.radiobutton_SO_Npisp,handles.radiobutton_SO_Nnarrow,handles.radiobutton_SO_Nrandom,handles.radiobutton_SO_Nback];
mutual_exclude(off)
global N F P t
N=0;F=0;P=0;t=0;
if get(handles.togglebutton_Npiap,'Value')==get(handles.togglebutton_Npiap,'Max')%缺点,是不能在原来状态下有反映,因为用的是回调函数而没有用switch判断来做出反应
if get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')
if get(hObject,'Value')==get(hObject,'Max')
    global Tname N F P Npinp Fpinp Ppinp tpinp t
    Tname='异步工频周期脉冲噪声';
    N=Npinp;F=Fpinp;P=Ppinp;t=tpinp;
end
end
end


% --- Executes on button press in radiobutton_SO_Nrandom.
function radiobutton_SO_Nrandom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SO_Nrandom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SO_Nrandom
off=[handles.radiobutton_SO_Npisp,handles.radiobutton_SO_Npiap,handles.radiobutton_SO_Nnarrow,handles.radiobutton_SO_Nback];
mutual_exclude(off)
global N F P t
N=0;F=0;P=0;t=0;
if get(handles.togglebutton_Nrandom,'Value')==get(handles.togglebutton_Nrandom,'Max')%缺点,是不能在原来状态下有反映,因为用的是回调函数而没有用switch判断来做出反应
if get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')
if get(hObject,'Value')==get(hObject,'Max')
    global Tname N F P Nran Fran Pran tran t
    Tname='随机脉冲噪声';
    N=Nran;F=Fran;P=Pran;t=tran;
end
end
end

% --- Executes on button press in radiobutton_SO_Nback.
function radiobutton_SO_Nback_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_SO_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_SO_Nback
off=[handles.radiobutton_SO_Npisp,handles.radiobutton_SO_Npiap,handles.radiobutton_SO_Nrandom,handles.radiobutton_SO_Nnarrow];
mutual_exclude(off)
global N F P t
N=0;F=0;P=0;t=0;
if get(handles.togglebutton_Nback,'Value')==get(handles.togglebutton_Nback,'Max')%缺点,是不能在原来状态下有反映,因为用的是回调函数而没有用switch判断来做出反应
if get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')
if get(hObject,'Value')==get(hObject,'Max')
    global Tname N F P Nback Fback Pback tback t
    Tname='有色背景噪声';
    N=Nback;F=Fback;P=Pback;t=tback;
end
end
end

% --- Executes on button press in checkbox1.
function checkbox_SC_Nnarrow_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
global Nnar Fnar Pnar fr t_sim is_narrow;
if is_narrow==1
if (get(hObject,'Value') == get(hObject,'Max'))
    axes(handles.axes2);
    plot(t_sim,Nnar);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fnar);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pnar);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
end
% --- Executes on button press in checkbox2.
function checkbox_SC_Npisp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
    global Npisp Fpisp Ppisp fr t_sim is_syn;
    if (is_syn==1)
    if (get(hObject,'Value') == get(hObject,'Max'))
    axes(handles.axes2);
    plot(t_sim,Npisp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpisp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppisp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
    end
    end

% --- Executes on button press in checkbox3.
function checkbox_SC_Npiap_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
    global Npinp Fpinp Ppinp fr t_sim is_nsyn;
    if (is_nsyn==1)
    if (get(hObject,'Value') == get(hObject,'Max'))
    axes(handles.axes2);
    plot(t_sim,Npinp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpinp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppinp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)'); 
    end
    end

% --- Executes on button press in checkbox4.
function checkbox_SC_Nrandom_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
    global Nran Fran Pran fr t_sim is_rand;
    if (is_rand==1)
    if (get(hObject,'Value') == get(hObject,'Max'))
    axes(handles.axes2);
    plot(t_sim,Nran);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fran);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pran);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');  
    end
    end

% --- Executes on button press in checkbox5.
function checkbox_SC_Nback_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
    global Nback Fback Pback fr t_sim is_colord;
    if (is_colord==1)
    if (get(hObject,'Value') == get(hObject,'Max'))
    axes(handles.axes2);
    plot(t_sim,Nback);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fback);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pback);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)'); 
    end
    end

% --- Executes on button press in radiobutton_waveform.
function radiobutton_waveform_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_waveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_waveform
off=[handles.radiobutton9,handles.radiobutton10];
mutual_exclude(off)
 %为何在没有运行任何一个噪声生成程序的时候仍旧能画出图形?数据是存储在哪里的?
global N
if find(N)>0
if (get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')&(get(handles.togglebutton_Nnarrow,'Value')==get(handles.togglebutton_Nnarrow,'Max')|get(handles.togglebutton_Npisp,'Value')==get(handles.togglebutton_Npisp,'Max')|get(handles.togglebutton_Npiap,'Value')==get(handles.togglebutton_Npiap,'Max')|get(handles.togglebutton_Nrandom,'Value')==get(handles.togglebutton_Nrandom,'Max')|get(handles.togglebutton_Nback,'Value')==get(handles.togglebutton_Nback,'Max')))|get(handles.togglebutton_SC,'Value')==get(handles.togglebutton_SC,'Max')
    if get(hObject,'Value')==get(hObject,'Max')
    global t N Tname
    axes(handles.axes2);
    plot(t,N)
    title(Tname)
    xlabel('时间 (s)')
    ylabel('幅度 (V)')
end
end
else
    axes(handles.axes2);
    cla;
end

% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
off=[handles.radiobutton_waveform,handles.radiobutton10];
mutual_exclude(off)
global F
if find(F)>0
if (get(handles.togglebutton_SO,'Value')==1&(get(handles.togglebutton_Nnarrow,'Value')==get(handles.togglebutton_Nnarrow,'Max')|get(handles.togglebutton_Npisp,'Value')==get(handles.togglebutton_Npisp,'Max')|get(handles.togglebutton_Npiap,'Value')==get(handles.togglebutton_Npiap,'Max')|get(handles.togglebutton_Nrandom,'Value')==get(handles.togglebutton_Nrandom,'Max')|get(handles.togglebutton_Nback,'Value')==get(handles.togglebutton_Nback,'Max')))|get(handles.togglebutton_SC,'Value')==get(handles.togglebutton_SC,'Max')
    if get(hObject,'Value')==get(hObject,'Max')
    global fr F Ns%有问题,这样不管选什么噪声都会有图形出来??不一定 
    axes(handles.axes2);
    plot(fr,2*F(1:Ns/2));
    title('频谱')
    xlabel('频率 (Hz)')
    ylabel('幅度 (V)')
end
end
else
    axes(handles.axes2);
    cla;
end


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
off=[handles.radiobutton_waveform,handles.radiobutton9];
mutual_exclude(off)
global P
if find(P)>0
if (get(handles.togglebutton_SO,'Value')==get(handles.togglebutton_SO,'Max')&(get(handles.togglebutton_Nnarrow,'Value')==get(handles.togglebutton_Nnarrow,'Max')|get(handles.togglebutton_Npisp,'Value')==get(handles.togglebutton_Npisp,'Max')|get(handles.togglebutton_Npiap,'Value')==get(handles.togglebutton_Npiap,'Max')|get(handles.togglebutton_Nrandom,'Value')==get(handles.togglebutton_Nrandom,'Max')|get(handles.togglebutton_Nback,'Value')==get(handles.togglebutton_Nback,'Max')))|get(handles.togglebutton_SC,'Value')==get(handles.togglebutton_SC,'Max')
    if get(hObject,'Value')==get(hObject,'Max')
    global fr P Ns 
    axes(handles.axes2);
    plot(fr,2*P(1:Ns/2))
    title('功率谱')
    xlabel('频率 (Hz)')
    ylabel('幅度 (V)')
end
end
else
    axes(handles.axes2);
    cla;
end

% --- Executes on button press in togglebutton_Npisp.
function togglebutton_Npisp_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Npisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
global Npisp Fpisp Ppisp fr t_sim is_syn;
Npisp=0;Fpisp=0;Ppisp=0;fr=0;is_syn=0;
if get(hObject,'Value')==get(hObject,'Max')
v_pisp_default=get(handles.radiobutton_Npisp_Default,'Value');
v_pisp_customer=get(handles.radiobutton_Npisp_Custom,'Value');
nSCR=fix(get(handles.slider_Npisp_SCR,'Value'));
if  (v_pisp_default==1)
[Npisp,Fpisp,Ppisp,fr]=noise_synchronous(0);
    is_syn=1;
    axes(handles.axes2);
    plot(t_sim,Npisp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpisp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppisp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
elseif v_pisp_customer==1 
    [Npisp,Fpisp,Ppisp,fr]=noise_synchronous(1,nSCR);
    is_syn=1;
    axes(handles.axes2);
    plot(t_sim,Npisp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpisp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppisp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
else
    is_syn=0;
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
end
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Npisp


% --- Executes on button press in radiobutton_Npisp_Default.
function radiobutton_Npisp_Default_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Npisp_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Npisp_Default
off=[handles.radiobutton_Npisp_Custom];
mutual_exclude(off)


% --- Executes on button press in radiobutton_Npisp_Custom.
function radiobutton_Npisp_Custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Npisp_Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Npisp_Custom
off=[handles.radiobutton_Npisp_Default];
mutual_exclude(off)


% --- Executes during object creation, after setting all properties.
function slider_Npisp_SCR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Npisp_SCR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Npisp_SCR_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Npisp_SCR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit6,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes on button press in togglebutton_Npiap.
function togglebutton_Npiap_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Npiap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Npiap

global Npinp Fpinp Ppinp fr t_sim is_nsyn;
Npinp=0;Fpinp=0;Ppinp=0;fr=0;is_nsyn=0;
if get(hObject,'Value')==get(hObject,'Max')
v_pinp_default=get(handles.radiobutton_Npiap_Default,'Value');
v_pinp_customer=get(handles.radiobutton_Npiap_Custom,'Value');
nPC=fix(get(handles.slider_Npiap_PC,'Value'));
nTV=fix(get(handles.slider_Npiap_TV,'Value'));
if  (v_pinp_default==1)
[Npinp,Fpinp,Ppinp,fr]=noise_asynchronous(0);
is_nsyn=1;
    axes(handles.axes2);
    plot(t_sim,Npinp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpinp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppinp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');    
elseif v_pinp_customer==1 
    [Npinp,Fpinp,Ppinp,fr]=noise_asynchronous(1,nPC,nTV);
    is_nsyn=1;
    axes(handles.axes2);
    plot(t_sim,Npinp);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fpinp);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Ppinp);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
else
    is_nsyn=0;
        axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
end

% --- Executes on button press in radiobutton_Npiap_Default.
function radiobutton_Npiap_Default_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Npiap_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Npiap_Default
off=[handles.radiobutton_Npiap_Custom];
mutual_exclude(off)

% --- Executes on button press in radiobutton14.
function radiobutton_Npiap_Custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton14
off=[handles.radiobutton_Npiap_Default];
mutual_exclude(off)

% --- Executes during object creation, after setting all properties.
function slider_Npiap_PC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Npiap_PC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Npiap_PC_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Npiap_PC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit7,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Npiap_TV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Npiap_TV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Npiap_TV_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Npiap_TV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit8,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in togglebutton_Nrandom.
function togglebutton_Nrandom_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Nrandom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes14);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Nrandom

global Nran Fran Pran fr t_sim is_rand;
Nran=0;Fran=0;Pran=0;fr=0;is_rand=0;
if get(hObject,'Value')==get(hObject,'Max')
v_ran_default=get(handles.radiobutton_Nrandom_Default,'Value');
v_ran_customer=get(handles.radiobutton_Nrandom_Custom,'Value');
nPulse=fix(get(handles.slider_Nrandom_impulse,'Value'));
if  (v_ran_default==1)
[Nran,Fran,Pran,fr]=noise_rand(0);
is_rand=1;
    axes(handles.axes2);
    plot(t_sim,Nran);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fran);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pran);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');    
elseif v_ran_customer==1 
    [Nran,Fran,Pran,fr]=noise_rand(1,nPulse);
    is_rand=1;
    axes(handles.axes2);
    plot(t_sim,Nran);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fran);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pran);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
else
    is_rand=0;
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes14);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
end

% --- Executes on button press in radiobutton_Nrandom_Default.
function radiobutton_Nrandom_Default_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nrandom_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nrandom_Default
off=[handles.radiobutton_Nrandom_Custom];
mutual_exclude(off)

% --- Executes on button press in radiobutton_Nrandom_Custom.
function radiobutton_Nrandom_Custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nrandom_Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nrandom_Custom
off=[handles.radiobutton_Nrandom_Default];
mutual_exclude(off)

% --- Executes during object creation, after setting all properties.
function slider_Nrandom_impulse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Nrandom_impulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_Nrandom_impulse_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Nrandom_impulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit9,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in togglebutton_Nback.
function togglebutton_Nback_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Nback

global Nback Fback Pback fr t_sim is_colord;
Nback=0;Fback=0;Pback=0;fr=0;is_colord=0;
if get(hObject,'Value')==get(hObject,'Max')
v_back_default=get(handles.radiobutton_Nback_Default,'Value');
v_back_customer=get(handles.radiobutton_Nback_Custom,'Value');
n_middle=fix(get(handles.slider_Nback,'Value'));%得到用户输入的短波电台数量的值
n_middle=(n_middle+2)/10;
t_s=1/(6*10^7);
t_sim=0:t_s:0.02;

if  (v_back_default==1)
    [Nback,Fback,Pback,fr]=noise_colored(0);
    is_colord=1;
    axes(handles.axes2);
    plot(t_sim,Nback);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fback);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pback);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
elseif v_back_customer==1 
    [Nback,Fback,Pback,fr]=noise_colored(1,n_middle);
    is_colord=1;
    axes(handles.axes2);
    plot(t_sim,Nback);
    xlabel('时间 (s)');
    ylabel('幅度 (V)');
    axes(handles.axes12);
    plot(fr,Fback);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axes(handles.axes13);
    plot(fr,Pback);
    xlabel('频率 (Hz)');
    ylabel('功率 (W)');
end
else
    is_colord=0;
    axes(handles.axes2);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes12);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
    axes(handles.axes13);
    cla;set(gca,'XTick',[]);set(gca,'YTick',[]);
end

% --- Executes on button press in radiobutton_Nback_Default.
function radiobutton_Nback_Default_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nback_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nback_Default
off=[handles.radiobutton_Nback_Custom];
mutual_exclude(off)

% --- Executes on button press in radiobutton_Nback_Custom.
function radiobutton_Nback_Custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Nback_Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Nback_Custom
off=[handles.radiobutton_Nback_Default];
mutual_exclude(off)



% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes on button press in pushbutton_Nback_Select.
function pushbutton_Nback_Select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Nback_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename pathname
if get(handles.radiobutton_Nback_Custom,'Value')==1
[filename, pathname, filterindex] = uigetfile('*.txt', 'Pick an txt-file');
set(handles.edit10,'String',[pathname,filename]);
end

% --- Executes on button press in pushbutton_Nback_Load.
function pushbutton_Nback_Load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Nback_Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FreqNback
if get(hObject,'Value')==0
    FreqNback=0;
else
global filename pathname 
FreqNback=load([pathname,filename]);
end


% --- Executes on slider movement.
function slider_Nback_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit12,'String',num2str(get(hObject,'Value')));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%set(handles.edit12,'String',num2str(fix(get(hObject,'Value'))));
%set(handles.edit12,'String',num2str(fix(get(hObject,'Value'))));

% --- Executes during object creation, after setting all properties.
function slider_Nback_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton26.
function radiobutton26_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton26


% --- Executes on button press in radiobutton27.
function radiobutton27_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton27


% --- Executes on button press in radiobutton_narrow_day.
function radiobutton_narrow_day_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_narrow_day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_narrow_day
off=[handles.radiobutton_narrow_night];
mutual_exclude(off);


% --- Executes on button press in radiobutton_narrow_night.
function radiobutton_narrow_night_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_narrow_night (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_narrow_night
off=[handles.radiobutton_narrow_day];
mutual_exclude(off);


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes on slider movement.
function slider14_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit12,'String',num2str(fix(get(hObject,'Value'))));
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Nback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
