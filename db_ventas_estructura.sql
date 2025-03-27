-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-03-2025 a las 03:00:42
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `db_ventas`
--

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `cantidad_envios_por_estado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `cantidad_envios_por_estado` (
`Cantidad_Envios` bigint(21)
,`estado` varchar(15)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `cantidad_vendida_por_categoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `cantidad_vendida_por_categoria` (
`Categoría` varchar(20)
,`Cantidad Vendida` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_categoria` int(11) NOT NULL,
  `categoria` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(25) NOT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `localidad` varchar(25) DEFAULT NULL,
  `provincia` varchar(25) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `envio`
--

CREATE TABLE `envio` (
  `id_envio` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `fecha_envio` date DEFAULT NULL,
  `estado` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `item`
--

CREATE TABLE `item` (
  `id_item` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medio_de_pago`
--

CREATE TABLE `medio_de_pago` (
  `id_medio_pago` int(11) NOT NULL,
  `medio_de_pago` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_de_compra`
--

CREATE TABLE `orden_de_compra` (
  `id_orden` int(11) NOT NULL,
  `fecha_orden` date NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `monto_total` decimal(8,2) DEFAULT 0.00,
  `id_medio_pago` int(11) NOT NULL,
  `id_envio` int(11) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `orden_de_compra`
--
DELIMITER $$
CREATE TRIGGER `before_delete_order` BEFORE DELETE ON `orden_de_compra` FOR EACH ROW BEGIN
    -- Registrar el evento de eliminación en la tabla de auditoría
    INSERT INTO orden_de_compra_auditoria (
        id_orden,
        accion,
        fecha_evento
    )
    VALUES (
        OLD.id_orden,
        'DELETE',
        NOW()
    );
    -- Eliminar los ítems relacionados con la orden
    DELETE FROM item
    WHERE id_orden = OLD.id_orden;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_de_compra_auditoria`
--

CREATE TABLE `orden_de_compra_auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `accion` varchar(50) DEFAULT NULL,
  `fecha_evento` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `id_producto` int(11) NOT NULL,
  `nombre` varchar(25) NOT NULL,
  `precio` decimal(8,2) DEFAULT 0.00,
  `id_categoria` int(11) NOT NULL,
  `marca` varchar(25) DEFAULT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `id_proveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `producto`
--
DELIMITER $$
CREATE TRIGGER `after_price_update` AFTER UPDATE ON `producto` FOR EACH ROW BEGIN
    -- Verificar si el precio fue modificado
    IF OLD.precio != NEW.precio THEN
        -- Insertar un registro en la tabla de auditoría
        INSERT INTO producto_auditoria (
            id_producto,
            precio_anterior,
            precio_nuevo,
            fecha_cambio
        )
        VALUES (
            NEW.id_producto,
            OLD.precio,
            NEW.precio,
            NOW()
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `productos_mas_vendidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `productos_mas_vendidos` (
`Producto Más Vendido` int(11)
,`Nombre del Producto` varchar(25)
,`Cantidad Vendida` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_auditoria`
--

CREATE TABLE `producto_auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `fecha_cambio` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `promedio_productos_vendidos_x_categoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `promedio_productos_vendidos_x_categoria` (
`Categoría` varchar(20)
,`Promedio de Productos Vendidos` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL,
  `proveedor` varchar(50) NOT NULL,
  `contacto` varchar(25) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `telefonos` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo`
--

CREATE TABLE `tipo` (
  `id_tipo` int(11) NOT NULL,
  `tipo_venta` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `total_ventas_por_mes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `total_ventas_por_mes` (
`mes` varchar(7)
,`total_ventas` decimal(30,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `cantidad_envios_por_estado`
--
DROP TABLE IF EXISTS `cantidad_envios_por_estado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cantidad_envios_por_estado`  AS SELECT count(0) AS `Cantidad_Envios`, `envio`.`estado` AS `estado` FROM `envio` GROUP BY `envio`.`estado` ORDER BY count(0) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `cantidad_vendida_por_categoria`
--
DROP TABLE IF EXISTS `cantidad_vendida_por_categoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cantidad_vendida_por_categoria`  AS SELECT `c`.`categoria` AS `Categoría`, sum(`i`.`cantidad`) AS `Cantidad Vendida` FROM (((`orden_de_compra` `oc` join `item` `i` on(`oc`.`id_orden` = `i`.`id_orden`)) join `producto` `p` on(`i`.`id_producto` = `p`.`id_producto`)) join `categoria` `c` on(`p`.`id_categoria` = `c`.`id_categoria`)) GROUP BY `c`.`categoria` ORDER BY sum(`i`.`cantidad`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `productos_mas_vendidos`
--
DROP TABLE IF EXISTS `productos_mas_vendidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `productos_mas_vendidos`  AS SELECT `p`.`id_producto` AS `Producto Más Vendido`, `p`.`nombre` AS `Nombre del Producto`, sum(`i`.`cantidad`) AS `Cantidad Vendida` FROM ((`orden_de_compra` `oc` join `item` `i` on(`oc`.`id_orden` = `i`.`id_orden`)) join `producto` `p` on(`i`.`id_producto` = `p`.`id_producto`)) GROUP BY `p`.`id_producto`, `p`.`nombre` ORDER BY sum(`i`.`cantidad`) DESC LIMIT 0, 10 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `promedio_productos_vendidos_x_categoria`
--
DROP TABLE IF EXISTS `promedio_productos_vendidos_x_categoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `promedio_productos_vendidos_x_categoria`  AS SELECT `c`.`categoria` AS `Categoría`, avg(`i`.`cantidad`) AS `Promedio de Productos Vendidos` FROM (((`orden_de_compra` `oc` join `item` `i` on(`oc`.`id_orden` = `i`.`id_orden`)) join `producto` `p` on(`i`.`id_producto` = `p`.`id_producto`)) join `categoria` `c` on(`p`.`id_categoria` = `c`.`id_categoria`)) GROUP BY `c`.`categoria` ORDER BY avg(`i`.`cantidad`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `total_ventas_por_mes`
--
DROP TABLE IF EXISTS `total_ventas_por_mes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_ventas_por_mes`  AS SELECT date_format(`orden_de_compra`.`fecha_orden`,'%Y-%m') AS `mes`, sum(`orden_de_compra`.`monto_total`) AS `total_ventas` FROM `orden_de_compra` GROUP BY date_format(`orden_de_compra`.`fecha_orden`,'%Y-%m') ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indices de la tabla `envio`
--
ALTER TABLE `envio`
  ADD PRIMARY KEY (`id_envio`);

--
-- Indices de la tabla `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`id_item`),
  ADD KEY `FK_ITEM_ORDEN` (`id_orden`),
  ADD KEY `FK_ITEM_PRODUCTO` (`id_producto`),
  ADD KEY `FK_ITEM_TIPO` (`id_tipo`);

--
-- Indices de la tabla `medio_de_pago`
--
ALTER TABLE `medio_de_pago`
  ADD PRIMARY KEY (`id_medio_pago`);

--
-- Indices de la tabla `orden_de_compra`
--
ALTER TABLE `orden_de_compra`
  ADD PRIMARY KEY (`id_orden`),
  ADD KEY `FK_CLIENTE` (`id_cliente`),
  ADD KEY `FK_MEDIO_PAGO` (`id_medio_pago`),
  ADD KEY `FK_ENVIO` (`id_envio`),
  ADD KEY `FK_TIPO` (`id_tipo`);

--
-- Indices de la tabla `orden_de_compra_auditoria`
--
ALTER TABLE `orden_de_compra_auditoria`
  ADD PRIMARY KEY (`id_auditoria`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `FK_CATEGORIA` (`id_categoria`),
  ADD KEY `FK_PROVEEDOR` (`id_proveedor`);

--
-- Indices de la tabla `producto_auditoria`
--
ALTER TABLE `producto_auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`);

--
-- Indices de la tabla `tipo`
--
ALTER TABLE `tipo`
  ADD PRIMARY KEY (`id_tipo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `envio`
--
ALTER TABLE `envio`
  MODIFY `id_envio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `item`
--
ALTER TABLE `item`
  MODIFY `id_item` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `medio_de_pago`
--
ALTER TABLE `medio_de_pago`
  MODIFY `id_medio_pago` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_de_compra`
--
ALTER TABLE `orden_de_compra`
  MODIFY `id_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_de_compra_auditoria`
--
ALTER TABLE `orden_de_compra_auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `producto_auditoria`
--
ALTER TABLE `producto_auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipo`
--
ALTER TABLE `tipo`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `item`
--
ALTER TABLE `item`
  ADD CONSTRAINT `FK_ITEM_ORDEN` FOREIGN KEY (`id_orden`) REFERENCES `orden_de_compra` (`id_orden`),
  ADD CONSTRAINT `FK_ITEM_PRODUCTO` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `FK_ITEM_TIPO` FOREIGN KEY (`id_tipo`) REFERENCES `tipo` (`id_tipo`);

--
-- Filtros para la tabla `orden_de_compra`
--
ALTER TABLE `orden_de_compra`
  ADD CONSTRAINT `FK_CLIENTE` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `FK_ENVIO` FOREIGN KEY (`id_envio`) REFERENCES `envio` (`id_envio`),
  ADD CONSTRAINT `FK_MEDIO_PAGO` FOREIGN KEY (`id_medio_pago`) REFERENCES `medio_de_pago` (`id_medio_pago`),
  ADD CONSTRAINT `FK_TIPO` FOREIGN KEY (`id_tipo`) REFERENCES `tipo` (`id_tipo`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `FK_CATEGORIA` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  ADD CONSTRAINT `FK_PROVEEDOR` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`);

--
-- Filtros para la tabla `producto_auditoria`
--
ALTER TABLE `producto_auditoria`
  ADD CONSTRAINT `producto_auditoria_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
