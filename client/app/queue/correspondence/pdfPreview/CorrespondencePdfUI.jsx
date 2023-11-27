import React, { useEffect, useMemo, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import * as pdfjs from 'pdfjs-dist';
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker.entry';
import { css } from 'glamor';
import classNames from 'classnames';
import _ from 'lodash';
import CorrespondencePdfDocument from './CorrespondencePdfDocument';
import CorrespondencePdfToolBar from './CorrespondencePdfToolBar';
import ApiUtil from '../../../util/ApiUtil';
import { pageNumberOfPageIndex } from '../../../reader/utils';
import { PDF_PAGE_HEIGHT, PDF_PAGE_WIDTH } from '../../../reader/constants';
import { CorrespondencePdfFooter } from './CorrespondencePdfFooter';
import uuid from 'uuid';

pdfjs.GlobalWorkerOptions.workerSrc = pdfjsWorker;

/**
 * Represents the root layout and component structure for viewing PDF files
 * @param {Object} doc - Document metadata obtained from Document Controller
 * @param {string} documentPathBase - String path containing appeal Id. Directs to /:appeal_id/documents
 */
const CorrespondencePdfUI = () => {
  // Destructured Props and State
  // const {
  //   documentPathBase,
  //   doc
  // } = props;

  // Hard Coded Temp Data Objects
  const documentPathBase = '/2941741/documents';
  const doc = {
    id: 13,
    category_medical: null,
    category_other: null,
    category_procedural: null,
    created_at: '2023-11-16T10:08:41.948-05:00',
    description: null,
    file_number: '686623298',
    previous_document_version_id: null,
    received_at: '2023-11-17',
    series_id: '4230620',
    type: 'Private Medical Treatment Record',
    updated_at: '2023-11-20T14:58:49.681-05:00',
    upload_date: '2023-11-18',
    vbms_document_id: '110',
    content_url: '/document/13/pdf',
    filename: 'filename-9265746.pdf',
    category_case_summary: true,
    serialized_vacols_date: '',
    serialized_receipt_date: '11/17/2023',
    'matching?': false,
    opened_by_current_user: true,
    tags: [],
    receivedAt: '2023-11-17',
    listComments: false,
    wasUpdated: false
  };

  // useRefs (persist data through React render cycle)

  // Contains a ref to each canvas DOM element generated after document loads
  const canvasRefs = useRef([]);

  // useStates (re-renders components on change)
  const [viewport, setViewPort] = useState({
    height: PDF_PAGE_HEIGHT,
    width: PDF_PAGE_WIDTH
  });
  const [scale, setScale] = useState(1);
  const [rotation, setRotation] = useState(0);
  const [searchBarToggle, setSearchBarToggle] = useState(false);
  const [pdfDocProxy, setPdfDocProxy] = useState(null);
  const [pdfPageProxies, setPdfPageProxies] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);

  // Once the component loads, we fetch the document from the Document Controller
  // and retrieve the document content via pdfjs library's PdfDocumentProxy object.
  // See https://mozilla.github.io/pdf.js/api/draft/module-pdfjsLib-PDFDocumentProxy.html
  useEffect(() => {
    const getAllPages = async (pdfDocument) => {
      const promises = _.range(0, pdfDocument?.numPages).map((index) => {
        return pdfDocument.getPage(pageNumberOfPageIndex(index));
      });

      return Promise.all(promises);
    };

    const loadPdf = async () => {
      const response = await ApiUtil.get(`${doc.content_url}`, {
        cache: true,
        withCredentials: true,
        timeout: true,
        responseType: 'arraybuffer',
      });
      const loadingTask = pdfjs.getDocument({ data: response.body });
      const pdfDocument = await loadingTask.promise;

      const pages = await getAllPages(pdfDocument);

      setPdfDocProxy(pdfDocument);
      setPdfPageProxies(pages);
    };

    loadPdf();

    return () => {
      pdfDocProxy.destroy();
    };
  }, []);

  // Constants
  const ZOOM_RATE = 0.3;
  const MINIMUM_ZOOM = 0.1;

  const ROTATION_INCREMENTS = 90;
  const COMPLETE_ROTATION = 360;

  const pdfWrapper = css({
    '@media(max-width: 920px)': {
      width: 'unset',
      right: '250px' },
    '@media(min-width: 1240px )': {
      width: 'unset',
      right: '380px' }
  });

  // ////////////// //
  // PDF Functions  //
  // ////////////// //

  // Zoom
  const zoomOut = () => {
    const nextScale = Math.max(MINIMUM_ZOOM, _.round(scale - ZOOM_RATE, 2));

    setScale(nextScale);
  };

  const zoomIn = () => {
    const nextScale = Math.max(MINIMUM_ZOOM, _.round(scale + ZOOM_RATE, 2));

    setScale(nextScale);
  };

  const fitToScreen = () => {
    setScale(1);
  };

  // Rotations
  const handleDocumentRotation = (docId) => {
    setRotation((prev) => (prev + 90) % 360);
  };

  // Search Bar
  const handleSearchBarToggle = () => {
    setSearchBarToggle(!searchBarToggle);
  };

  // Footer Pagination
  const handleSetPage = (val) => {
    console.log(val);
    setCurrentPage(val);
  };

  // After the doc is fetched, we count the number of pages.
  // We then generate an array of canvases for each page. We do not re-render these canvases, instead we should use
  // An effect where we repaint the canvases using the new viewport contexts

  const renderCanvases = () => {
    if (!pdfDocProxy) {
      return <div>Loading...</div>;
    }

    return pdfPageProxies.map((page, index) =>
      <CorrespondencePdfPage index={index} canvasRefs={canvasRefs} id={uuid()} />
    );
  };

  const memoizeCanvases = useMemo(renderCanvases, [pdfDocProxy]);

  const drawPage = (page, index) => {
    const canvas = document.getElementById(`canvas-${index}`);
    const context = canvas.getContext('2d');
    const viewport = page.getViewport({ scale });

    canvas.width = viewport.width;
    canvas.height = viewport.height;

    const renderOptions = {
      canvasContext: context,
      viewport,
    };

    page.render(renderOptions);
  };

  const drawAllPages = () => {
    pdfPageProxies.forEach((page, index) => {
      drawPage(page, index);
    });
  };

  if (!pdfDocProxy || !pdfPageProxies) {
    return <div>Loading...</div>;
  }

  return (
    <div className="cf-pdf-preview-container" {...pdfWrapper}>
      <CorrespondencePdfToolBar
        doc={doc}
        documentPathBase={documentPathBase}
        zoomIn={zoomIn}
        zoomOut={zoomOut}
        fitToScreen={fitToScreen}
        handleDocumentRotation={handleDocumentRotation}
        handleSearchBarToggle={handleSearchBarToggle} />
      <div>
        {/* <div className="cf-pdf-preview-scrollview">
          <div className="cf-pdf-preview-grid">
            {renderCanvases()}
          </div>
        </div> */}
        <CorrespondencePdfDocument
          pdfDocProxy={pdfDocProxy}
          pdfPageProxies={pdfPageProxies}
          scale={scale}
          viewport={viewport}
          setViewPort={setViewPort}
        />
        <CorrespondencePdfFooter
          currentPage={currentPage}
          setCurrentPage={handleSetPage}
          doc={pdfDocProxy}
        />
      </div>
    </div>
  );
};

const CorrespondencePdfPage = (props) => {
  const { canvasRefs, index, id } = props;

  return (
    <canvas
      id={`canvas-${index}`}
      className={`canvasWrapper ${id}`}
      ref={(ref) => (canvasRefs.current[index] = ref)} />
  );
};

export default CorrespondencePdfUI;
